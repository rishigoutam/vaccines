#' EDA for our covid providers data
#' Filtered reports from Shiny in report.Rmd

library(tidyverse)

covid <- readRDS("./data/covid.rds")

# Filters a user can pass
user_states <- c("WA", "CA", "OR")
user_vaccine_types <- c("Janssen", "Pfizer", "Pfizer_child")
user_insurance_accepted <- c(TRUE)
user_walkins_allows <- c(TRUE)

# Get the display name for vaccine
GetDisplayName <- function(vaccine_type) {
  switch (vaccine_type,
    Pfizer = "Pfizer (12+)",
    Pfizer_child = "Pfizer (5-11)",
    Moderna = "Moderna (18+)",
    Janssen = "Janssen (18+)"
  )
}

# Number of providers by state
covid %>%
  filter(state %in% user_states) %>%
  group_by(state) %>%
  summarise(num_providers = n()) %>%
  arrange(desc(num_providers)) %>%
  ggplot(aes(fct_rev(fct_reorder(state, num_providers)), num_providers)) +
  geom_col() +
  labs(x = "State/Territory", y = "Number of Vaccine Providers", title = "Number of Vaccine Providers by State")

# % Availability of user vaccines
covid_availability <- covid %>%
  filter(state %in% user_states) %>%
  mutate(across(user_vaccine_types, ~ (!is.na(.x) & !isFALSE(.x)) )) %>%
  select(c(location_guid, state, user_vaccine_types))

# need to wrap vaccine_type into .data[[vaccine_type]]
# see: https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html
# E.g,
# for (var in names(mtcars)) {
#   mtcars %>% count(.data[[var]])
# }
for (vaccine_type in user_vaccine_types) {
  vaccine_availability <-
    covid_availability %>%
      group_by(state, .data[[vaccine_type]]) %>%
      summarise(vaccine_count = n()) %>%
      mutate(vaccine_prop = 100*vaccine_count/sum(vaccine_count)) %>%
      filter(.data[[vaccine_type]] == TRUE)

  vaccine_name <- GetDisplayName(vaccine_type)
    print(
      ggplot(data = vaccine_availability, aes(fct_rev(fct_reorder(state, vaccine_prop)), vaccine_prop)) +
      geom_col() +
      labs(x = "State/Territory", y = str_c(vaccine_name, " in stock (%)"),
           title = str_glue("Percentage of Vaccine Providers having {vaccine_name} in stock by state"))
    )
}
