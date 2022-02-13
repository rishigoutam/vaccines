#' EDA for our covid providers data
#' Filtered reports from Shiny in report.Rmd

library(tidyverse)

covid <- readRDS("./data/covid.rds")

# Filters a user can pass
user_states <- c("WA", "CA", "OR")
user_vaccine_types <- c("Pfizer", "Pfizer_child")
user_insurance_accepted <- c(TRUE)
user_walkins_allows <- c(TRUE)

# Number of providers by state
covid %>%
  filter(state %in% user_states) %>%
  group_by(state) %>%
  summarise(num_providers = n()) %>%
  arrange(desc(num_providers)) %>%
  ggplot(aes(fct_rev(fct_reorder(state, num_providers)), num_providers)) +
  geom_col() +
  labs(x = "State", y = "Number of Vaccine Providers", title = "Number of Vaccine Providers by State")

# % Availability of Moderna
covid %>%
  mutate(Moderna = replace_na(c(Moderna), FALSE)) %>%
  group_by(state, Moderna) %>%
  summarise(Moderna_Available_Count = n()) %>%
  mutate(Moderna_Prop = Moderna_Available_Count / sum(Moderna_Available_Count))
