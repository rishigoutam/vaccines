function(input, output) {
  # Create information popup for each provider
  covid <- covid %>%
    mutate(provider_popup = str_glue(.na = "",
          '<div class="popup">',
           '<div class="name"><strong>Name: </strong><br>{name}</div>',
           '<div class="address"><br><strong>Address: </strong>',
           '<br>{street1} {street2}',
           '<br>{city}, {state} {zip}</div>',
           '<br><strong>Phone: </strong>{phone}',
           '<div class = "stock"><br><strong>In Stock: </strong>',
           '<span><br>J&J Janssen (18+): </span><span>{ifelse(Janssen, "Yes", "No")}</span>',
           '<br><span>Moderna (18+): <span>{ifelse (Moderna, "Yes", "No")}</span>',
           '<br><span>Pfizer (12+): <span>{ifelse(Pfizer, "Yes", "No")}</span>',
           '<br><span>Pfizer (5-11): <span>{ifelse (Pfizer_child, "Yes", "No")}</span></div>',
           '<br><strong>Insurance Accepted: </strong>{ifelse (!is.na(insurance_accepted) & insurance_accepted, "Yes", "No")}',
           '<br><strong>Walk-Ins Allowed: </strong>{ifelse (!is.na(walkins_accepted) & walkins_accepted, "Yes", "No")}',
          '</div>'))

  # Leaflet map
  output$cfmap <- renderLeaflet({
    leaflet(covid) %>%
      addTiles() %>%
      addAwesomeMarkers(data = covid, lat = ~latitude, lng = ~longitude,
                        popup = ~provider_popup, clusterOptions = markerClusterOptions(),
                        icon = awesomeIcons(icon = 'ion-medkit', iconColor = 'darkgreen',
                                            library = 'ion', markerColor = 'green'))
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
  colnames = c("Vaccine Provider", "City", "State", "ZIP", "Phone No.",
               "Accepts Insurance", "Walk-Ins Allowed",
               "Moderna (18+) In Stock", "Pfizer (12+) In Stock",
               "Pfizer (5-11) In Stock", "J&J Janssen (18+) In Stock"))
}
