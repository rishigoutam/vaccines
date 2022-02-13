# Preprocess our covid vaccine provider data and save as R Data file
# https://appsilon.com/fast-data-loading-from-files-to-r/

library(tidyverse)
library(dialr)

USE_AWS <- FALSE

# Load data ---------------------------------------------------------------

  # CDC covid vaccine provider locations
  # https://data.cdc.gov/Vaccinations/Vaccines-gov-COVID-19-vaccinating-provider-locatio/5jp2-pgaw
  if (USE_AWS) {
    library(aws.s3)
    covid <- s3read_using(FUN = read_csv,
                          bucket = 'awsgoutamorg-bucket',
                          object = 'Vaccines.gov__COVID-19_vaccinating_provider_locations.csv')
  } else {
    covid <- read_csv("./data/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv")
  }

## Select/rename columns --------------------------------------------------
covid <- covid %>%
  select(c(location_guid="provider_location_guid",
           phone="loc_phone",
           name="loc_name",
           street1="loc_admin_street1",
           street2="loc_admin_street2",
           city="loc_admin_city",
           state="loc_admin_state",
           zip="loc_admin_zip",              # keep 5 digits only
           "insurance_accepted",             # boolean
           "walkins_accepted",               # boolean
           "med_name",                       # Moderna, Pfizer, J&J
           "in_stock",                       # boolean
           # "supply_level",                 # -1 -> No report; 0 -> No supply;
           # 1 -> <1 day supply; 3 -> 1-2 day supply; 4 -> >2 day supply
           "latitude",
           "longitude",
           # category="Category"             # covid or seasonal. all are covid for covid. TODO keep if we want to check against flu dataset
  ))

## Basic Cleaning ---------------------------------------------------------

# 39 covid vaccine locations missing lat, long -> drop them
# zip is not provided for some providers -> remove these and only store short zip
# get only up to first five digits of zip. zip codes can be <5 characters
# change street names to uppercase
covid <- covid %>%
  drop_na(c('longitude', 'latitude')) %>%
  mutate(street1 = str_to_upper(street1)) %>%
  mutate(street2 = str_to_upper(street2)) %>%
  mutate(city = str_to_upper(city)) %>%
  mutate(state = str_to_upper(state)) %>%
  filter(zip != ".") %>%
  mutate(zip = as.numeric(str_extract(zip, "[0-9]+")))

# We have three zip codes that are 9 characters and are missing a hyphen.
# only take first five characters from these
covid <- covid %>%
  mutate(zip = ifelse(str_length(zip) > 5, str_sub(zip, 1, 5), zip))

# We have 230 zip codes of length 3 and 4,065 zip codes of length 4
# 3-length zip codes typically belong to the San Juan islands or the US Virgin Islands
# 4-length zip codes are typically military bases overseas or some east coast cities
# These "short" zip codes should be zero-padded on the left
# see: https://en.wikipedia.org/wiki/List_of_ZIP_Code_prefixes#Starts_with_0
covid <- covid %>%
  mutate(zip = str_pad(zip, 5, side = "left", pad = "0"))

## Clean vaccine type and availability -----------------------------------


# a provider location can have 3 (plus 1 for 5-11yr) types of vaccines but we
# see 10 types based on dosage in our dataset pfizer is approved for 5-11 and
# 12+ so is the only vaccine for children in our data at this point in time
# https://healthy.kaiserpermanente.org/pages/search?query=Pfizer-BioNTech%20COVID-19%20Vaccine&category=Drugs&global_region=All&language=English&binning-state=dose_form%3D%3DSuspension%20for%20reconstitution%0Aregion_label%3D%3DAll

# med_name                                                       `n()`
#   1 Janssen, COVID-19 Vaccine, 0.5 mL                              53496
#
# 2 Moderna, COVID-19 Vaccine, 100mcg/0.5mL                           34        # merge into below
# 3 Moderna, COVID-19 Vaccine, 100mcg/0.5mL 10 dose                56323        # moderna 10 doses/5.5mL vial
# 4 Moderna, COVID-19 Vaccine, 100mcg/0.5mL 10 doses                 863        # merge into above
# 5 Moderna, COVID-19 Vaccine, 100mcg/0.5mL 14 dose                45389        # moderna 14 doses/7.5mL vial.
# all moderna vaccines are the same

# 6 Pfizer-BioNTech, COVID-19 Vaccine, 10 mcg/0.2 mL, tris-sucrose 47424        # 5-11yr old (orange) (new formulation)
# 7 Pfizer-BioNTech, COVID-19 Vaccine, 3 mcg/0.2 mL, tris-sucrose    775        # typo merge with 12+ (new)
# 8 Pfizer-BioNTech, COVID-19 Vaccine, 30 mcg/0.3mL                55566        # 12+ (old formulation)
# 9 Pfizer-BioNTech, COVID-19 Vaccine, 30 mcg/0.3mL, tris-sucrose  29554        # 12+ (new formulation)
# 10 Pfizer, COVID-19 Vaccine, 30 mcg/0.3mL                           18        # typo merge with 12+ (old)
# we don't care about new/old formulation for pfizer so just separate 12+  from 5-11

# let's rename the vaccine name as per above
covid <- covid %>%
  mutate(med_name = case_when(
    str_detect(med_name,'Moderna') ~ 'Moderna',
    str_detect(med_name,'Janssen') ~ 'Janssen',
    str_detect(med_name,'(10 mcg)') ~ 'Pfizer_child',
    str_detect(med_name,'(30 mcg)|(3 mcg)') ~ 'Pfizer'))

# now we have squashed multiple vaccine types into the real types for each
# provider but could have duplicate rows the in_stock is the only value that
# could be different between rows. this should be whether any of the vaccine
# types are in stock
covid <- covid %>%
  group_by(location_guid, med_name) %>%
  mutate(in_stock = any(in_stock)) %>%
  distinct()

# now we should put our data in tidy data format where each row is a single
# provider location we currently have redundant data and are only seeing what
# vaccine types are in stock
covid <- covid %>%
  pivot_wider(names_from = med_name, values_from = in_stock)

## Format phone numbers----------------------------------------------------
# Note: this can take a minute or two to run!
phone_nums <- phone(covid$phone, "US")
covid$phone <- format(phone_nums, format = "NATIONAL", clean = FALSE)


# Create provider information column for map markers ----------------------

covid <- covid %>%
  mutate(provider_popup = str_glue(.na = "",
                                   '<div class="popup">',
                                   '<div class="name"><strong>Name: </strong><br>{name}</div>',
                                   '<div class="address"><br><strong>Address: </strong>',
                                   '<br>{street1} {street2}',
                                   '<br>{city}, {state} {zip}</div>',
                                   '<br><strong>Phone: </strong>{phone}',
                                   '<div class = "stock"><br><strong>In Stock: </strong>',
                                   '<span><br>J&J Janssen (18+): </span><span>{ifelse(!is.na(Janssen) & Janssen, "Yes", "No")}</span>',
                                   '<br><span>Moderna (18+): <span>{ifelse (!is.na(Moderna) & Moderna, "Yes", "No")}</span>',
                                   '<br><span>Pfizer (12+): <span>{ifelse(!is.na(Pfizer) & Pfizer, "Yes", "No")}</span>',
                                   '<br><span>Pfizer (5-11): <span>{ifelse (!is.na(Pfizer_child) & Pfizer_child, "Yes", "No")}</span></div>',
                                   '<br><strong>Insurance Accepted: </strong>{ifelse (!is.na(insurance_accepted) & insurance_accepted, "Yes", "No")}',
                                   '<br><strong>Walk-Ins Allowed: </strong>{ifelse (!is.na(walkins_accepted) & walkins_accepted, "Yes", "No")}',
                                   '</div>'))


# Create named list of states ---------------------------------------------

abbrv <- c("", sort(unique(covid$state))) # 55 states
# see: https://en.wikipedia.org/wiki/List_of_U.S._state_and_territory_abbreviations
state_names <- c("All",
                "Alaska",
                "Alabama",
                "Arkansas",
                "Arizona",
                "California",
                "Colorado",
                "Connecticut",
                "District of Columbia",
                "Delaware",
                "Florida",
                "Georgia",
                "Guam",
                "Hawaii",
                "Iowa",
                "Idaho",
                "Illinois",
                "Indiana",
                "Kansas",
                "Kentucky",
                "Louisiana",
                "Massachusetts",
                "Maryland",
                "Maine",
                "Michigan",
                "Minnesota",
                "Missouri",
                "Mississippi",
                "Montana",
                "North Carolina",
                "North Dakota",
                "Nebraska",
                "New Hampshire",
                "New Jersey",
                "New Mexico",
                "Nevada",
                "New York",
                "Ohio",
                "Oklahoma",
                "Oregon",
                "Pennsylvania",
                "Puerto Rico",
                "Palau",
                "Rhode Island",
                "South Carolina",
                "South Dakota",
                "Tennessee",
                "Texas",
                "Utah",
                "Virginia",
                "Virgin Islands",
                "Vermont",
                "Washington",
                "Wisconsin",
                "West Virginia",
                "Wyoming")

states <- setNames(abbrv, state_names)
# View(data.frame(state_names, abbrv))                # check

# Output R Data files -----------------------------------------------------

write_rds(covid, file = "./data/covid.rds")           # no compression for speed reading

# NOT RUN {
# covidrds <- read_rds(file = "./data/covid.rds")
# as.numeric(object.size(covidrds)/10^6)              # 74MB in memory
# file.size("./data/covid.rds")/10^6                  # 51MB on disk (uncompressed)
# }

write_rds(states, file = "./data/states.rds")
