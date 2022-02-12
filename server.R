# Vaccine Shiny app server
function(input, output) {
  # Create map using Leaflet
  # see: https://rstudio.github.io/leaflet/
  output$vaccine_map <- renderLeaflet({
    leaflet(covid) %>%
      addTiles() %>%
      # TODO marker should indicate availability
      addAwesomeMarkers(data = covid, lat = ~latitude, lng = ~longitude,
                        popup = ~provider_popup, clusterOptions = markerClusterOptions(),
                        icon = awesomeIcons(icon = 'ion-medkit', iconColor = 'darkgreen',
                                            library = 'ion', markerColor = 'green'))
  })

  # Display table using DT
  # see: https://rstudio.github.io/DT/
  output$covid <- DT::renderDataTable({
    data_display <- covid %>%
      relocate(name, city, state, zip, phone, insurance_accepted, walkins_accepted, Moderna, Pfizer, Pfizer_child, Janssen) %>%
      ungroup() %>%
      select(name, city, state, zip, phone, insurance_accepted, walkins_accepted, Moderna, Pfizer, Pfizer_child, Janssen)

    data_display #return the data to display
  },
  filter = 'top',
  rownames = FALSE,
  colnames = c("Vaccine Provider", "City", "State", "ZIP", "Phone No.",
               "Accepts Insurance", "Walk-Ins Allowed",
               "Moderna (18+) In Stock", "Pfizer (12+) In Stock",
               "Pfizer (5-11) In Stock", "J&J Janssen (18+) In Stock"))

  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)

      # Set up parameters to pass to Rmd document
      params <- list(state = input$state_input,
                     zip = input$zip_input,
                     file_type = input$file_type_input,
                     vaccine_type = input$vaccine_type_input)

      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
  })
}
