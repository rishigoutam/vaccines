shinyServer(function(input, output) {
  # Leaflet map
  output$cfmap <- renderLeaflet({
    leaflet(covid) %>%
      addCircles(lng = ~longitude, lat = ~latitude) %>%
      addTiles() %>%
      addCircleMarkers(data = covid, lat = ~latitude, lng = ~longitude,
                       radius = 3, stroke = FALSE, fillOpacity = 0.75)
  })

  # Display data (covid)
  output$covid <- DT::renderDataTable(covid) # TODO select cols
})
