setwd("~/vaccines/R")
library(tidyverse)

covid <- tbl_df(read.csv("../data/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv"))
flu <- tbl_df(read.csv("../data/Vaccines.gov__Flu_vaccinating_provider_locations.csv"))
both <- inner_join(flu, covid, by = "provider_location_guid") # TODO fix cols
View(both)
