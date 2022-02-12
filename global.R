library(shiny)
library(tidyverse)
library(DT)
library(leaflet)
library(dialr)

DEBUG <- FALSE

# CDC covid vaccine provider locations
# https://data.cdc.gov/Vaccinations/Vaccines-gov-COVID-19-vaccinating-provider-locatio/5jp2-pgaw
# covid <- read_csv("./data/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv")
covid <- read_rds("./data/covid.rds")

# Unused Data (for now)

# NYTimes Covid 19 data
# https://github.com/nytimes/covid-19-data
# masks <- read_csv("./data/mask-use-by-county.csv")

# WA DOH Dashboard
# https://www.doh.wa.gov/Emergencies/COVID19/DataDashboard#dashboard

# GeoJSON
# http://eric.clst.org/Stuff/USGeoJSON
# counties <- rgdal::readOGR("./data/gz_2010_us_050_00_5m.json")
# states <- rgdal::readOGR("./data/gz_2010_us_040_00_5m.json")
# outline <- rgdal::readOGR("./data/gz_2010_us_outline_5m.json")


#' filter by zip code for fewer markers in map
if (DEBUG) {
  covid <- covid %>%
    filter(zip %in% c("98604", "98101", "11225", "19607", "98052"))
}
