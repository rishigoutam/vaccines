library(shiny)
library(tidyverse)
library(DT)
library(leaflet)
setwd("~/vaccines/R")
covid <- tbl_df(read.csv("../data/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv", stringsAsFactors = FALSE))
flu <- tbl_df(read.csv("../data/Vaccines.gov__Flu_vaccinating_provider_locations.csv", stringsAsFactors = FALSE))

covid$latitude <- as.numeric(covid$latitude)
covid$longitude <- as.numeric(covid$longitude)

# Data Cleaning

# 39 covid vaccine locations missing lat, long
covid <- covid %>%
  drop_na(c('longitude', 'latitude'))
# 32 flu vaccine locations missing lat, long
flu <- flu %>%
  drop_na(c('longitude', 'latitude'))

#' TODO
#' Temporarily filter covid by zip
covid <- covid %>%
  filter(loc_admin_zip == "98604")

