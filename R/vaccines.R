setwd("~/vaccines/R")
library(tidyverse)

covid <- tbl_df(read.csv("../data/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv"))
# flu <- tbl_df(read.csv("../data/Vaccines.gov__Flu_vaccinating_provider_locations.csv"))
# both <- inner_join(flu, covid, by = "provider_location_guid") # TODO fix cols
# View(both)

# TODO
# reactive funcs
# observables
# csv -> sql and connect
# shinyapp.io vs local
#
# R:
# leaflet
# dplyr + ggplot visuals
# basic stats
# lm ????

covid$latitude <- as.numeric(covid$latitude)
covid$longitude <- as.numeric(covid$longitude)

# Data Cleaning
# 39 covid locations missing lat, long
sum(is.na(covid$latitude))
sum(is.na(covid$longitude))
# 32 flu locations missing lat, long
sum(is.na(flu$latitude))
sum(is.na(flu$longitude))

# Missing lat, long values
covid %>%
  filter(is.na(latitude))

colnames(covid)
head(covid)

covid_cols <- c("provider_location_guid", "loc_phone", )

