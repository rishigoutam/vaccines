function(input, output) {

  # Leaflet map
  output$cfmap <- renderLeaflet({
    leaflet(covid) %>%
      addTiles() %>%
      addMarkers(data = covid, lat = ~latitude, lng = ~longitude,
                 popup = ~provider_popup, clusterOptions = markerClusterOptions())
  })

  # Display table using DT
  # see: https://rstudio.github.io/DT/
  output$covid <- DT::renderDataTable({
    covid_display <- covid %>%
      relocate(name, city, state, zip, phone, insurance_accepted, walkins_accepted, Moderna, Pfizer, Pfizer_child, Janssen) %>%
      ungroup() %>%
      select(name, city, state, zip, phone, insurance_accepted, walkins_accepted, Moderna, Pfizer, Pfizer_child, Janssen)

    covid_display #return
  },
  filter = 'top',
  rownames = FALSE,
  colnames = c("Vaccine Provider", "City", "State", "ZIP", "Phone No.", "Accepts Insurance", "Walk-Ins Allowed", "Moderna (18+) In Stock", "Pfizer (12+) In Stock", "Pfizer (5-11) In Stock", "J&J Janssen (18+) In Stock"))
}
