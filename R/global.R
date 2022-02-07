library(shiny)
library(tidyverse)
library(DT)
library(leaflet)

covid <- tbl_df(read.csv("../data/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv", stringsAsFactors = FALSE))
flu <- tbl_df(read.csv("../data/Vaccines.gov__Flu_vaccinating_provider_locations.csv", stringsAsFactors = FALSE))

covid$latitude <- as.numeric(covid$latitude)
covid$longitude <- as.numeric(covid$longitude)

# Data Cleaning

# 39 covid locations missing lat, long
sum(is.na(covid$latitude))
sum(is.na(covid$longitude))
# 32 flu locations missing lat, long
sum(is.na(flu$latitude))
sum(is.na(flu$longitude))

covid %>%
  drop_na(c('longitude', 'latitude'))
flu %>%
  drop_na(c('longitude', 'latitude'))

