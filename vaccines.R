setwd("/Users/rishi/Documents/NYCDSA/Modules/vaccines")
library(tidyverse)
covid <- read.csv("Vaccines.gov__COVID-19_vaccinating_provider_locations.csv")
flu <- read.csv("Vaccines.gov__Flu_vaccinating_provider_locations.csv")

both <- inner_join(flu, covid, by = "provider_location_guid") # TODO fix cols
View(both)
