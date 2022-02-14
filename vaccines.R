#' EDA for our covid providers data
#' Filtered reports from Shiny in report.Rmd

library(tidyverse)
library(reshape2)
library(usmap)

df <- readRDS("./data/covid.rds")

# Filters a user can pass
# user_states <- c("WA", "CA", "OR")
user_states <- (sort(unique(covid$state)))
user_vaccine_types <- c("Moderna", "Janssen", "Pfizer", "Pfizer_child")
user_insurance_accepted <- c(TRUE)
user_walkins_allowed <- c(TRUE)

# Get the display name for vaccine
GetDisplayName <- function(vaccine_type) {
  switch (vaccine_type,
    Pfizer = "Pfizer (12+)",
    Pfizer_child = "Pfizer (5-11)",
    Moderna = "Moderna (18+)",
    Janssen = "Janssen (18+)"
  )
}

# Number of providers in US - no filters
nrow(df)

# Number of providers by state
df %>%
  filter(state %in% user_states) %>%
  group_by(state) %>%
  summarise(num_providers = n()) %>%
  arrange(desc(num_providers)) %>%
  ggplot(aes(fct_rev(fct_reorder(state, num_providers)), num_providers)) +
  geom_col() +
  labs(x = "State/Territory", y = "Number of Vaccine Providers", title = "Number of Vaccine Providers by State") +
  theme(plot.title = element_text(hjust = 0.5))

# % Availability of user vaccines
covid_availability <- df %>%
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
           title = str_glue("Percentage of Vaccine Providers having {vaccine_name} in stock by state")) +
      theme(plot.title = element_text(hjust = 0.5))
    )
}

# Do above but we want to see multiple types side by side
vaccine_prop_table <- tibble(state = user_states)

# TODO: fails if states in prop is less than user_states because we filtered out a state
for (vaccine_type in user_vaccine_types) {
  prop <- covid_availability %>%
    group_by(state, .data[[vaccine_type]]) %>%
    summarise(vaccine_count = n()) %>%
    mutate(vaccine_prop = 100*vaccine_count/sum(vaccine_count)) %>%
    filter(.data[[vaccine_type]] == TRUE)

  # see: https://stackoverflow.com/questions/25165197/r-create-new-column-with-name-coming-from-variable
  vaccine_prop_table[, vaccine_type] <- prop$vaccine_prop
}

# reshape to long
# see: https://stackoverflow.com/questions/58548522/multiple-variables-in-geom-bar-or-geom-col
vaccine_prop_table <- reshape2::melt(vaccine_prop_table, id.vars = "state")

# Plot the in stock percentages by state
prop_legend_labels <- sapply(user_vaccine_types, GetDisplayName)

vaccine_prop_table %>%
  ggplot(aes(x = state, value, fill = variable)) +
  geom_col(position = "dodge") +
  labs(x = "State/Territory", y = "Percent in stock",
       title = str_glue("Vaccines in stock by State and Vaccine Type"),
       fill = "Vaccine Type") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_fill_discrete(labels=prop_legend_labels)

# Get proportion of providers that accept insurance

covid_insurance <- df %>%
  filter(state %in% user_states) %>%
  select(location_guid, state, insurance_accepted) %>%
  mutate(insurance_accepted = ifelse(is.na(insurance_accepted), FALSE, insurance_accepted))

insurance_prop_table <- covid_insurance %>%
  group_by(state, insurance_accepted) %>%
  summarise(insurance_count = n()) %>%
  mutate(insurance_prop = 100*insurance_count/sum(insurance_count)) %>%
  filter(insurance_accepted == TRUE) %>%
  select(state, insurance_prop)

insurance_prop_table$fips <- fips(insurance_prop_table$state)
plot_usmap(data = insurance_prop_table,
           regions = "states",
           include = user_states,
           values = "insurance_prop",
           color = "darkgreen") +
  scale_fill_continuous(low = "lightgreen", high = "darkgreen",
                        name = "Insurance Acceptance Rate (%)", label = scales::comma) +
  theme(panel.background = element_rect(colour = "darkgreen")) +
  theme(legend.position = "right") +
  labs(title = "Insurance Acceptance at Vaccine Providers")

# Get proportion of providers that allow walkins in states
# TODO: refactor this with insurance code above as the code is identical

covid_walkins <- df %>%
  filter(state %in% user_states) %>%
  select(location_guid, state, walkins_accepted) %>%
  mutate(walkins_accepted = ifelse(is.na(walkins_accepted), FALSE, walkins_accepted))

walkins_prop_table <- covid_walkins %>%
  group_by(state, walkins_accepted) %>%
  summarise(walkins_count = n()) %>%
  mutate(walkins_prop = 100*walkins_count/sum(walkins_count)) %>%
  filter(walkins_accepted == TRUE) %>%
  select(state, walkins_prop)

walkins_prop_table$fips <- fips(walkins_prop_table$state)
plot_usmap(data = walkins_prop_table,
           regions = "states",
           include = user_states,
           values = "walkins_prop",
           color = "darkblue") +
  scale_fill_continuous(low = "lightblue", high = "darkblue",
                        name = "Walkins Allowed Rate (%)", label = scales::comma) +
  theme(panel.background = element_rect(colour = "darkblue")) +
  theme(legend.position = "right") +
  labs(title = "Walk-Ins Allowed at Vaccine Providers")
