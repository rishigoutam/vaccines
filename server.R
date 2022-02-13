# Vaccine Shiny app server
function(input, output) {
  # Filter data by user input
  vaccine_data <- reactive({
    filtered_data <- covid

    # Filter by state(s)
    # A multi select is null on initializing the app
    if(!is.null(input$state_input)) {
           filtered_data <- filtered_data %>%
             filter(state %in% input$state_input)
    }

    # Filter by provider preference (walkin, insurance)
    filtered_data <- filtered_data %>%
      filter(ifelse(input$walkin_input,
                    walkins_accepted == c(TRUE),
                    walkins_accepted %in% c(TRUE, FALSE, NA))) %>%
      filter(ifelse(input$insurance_input,
                    insurance_accepted == c(TRUE),
                    insurance_accepted %in% c(TRUE, FALSE, NA)))

    # Filter by type of vaccine
    vaccine_types <- input$vaccine_type_input
    if (!is.null(vaccine_types)) {
        filterByModerna <- "Moderna" %in% input$vaccine_type_input
        filterByPfizer <- "Pfizer" %in% input$vaccine_type_input
        filterByPfizerChild <- "Pfizer_child" %in% input$vaccine_type_input
        filterByJanssen <- "Janssen" %in% input$vaccine_type_input

        if (filterByModerna) {
          filtered_data <- filtered_data %>%
            filter(Moderna == TRUE)
        }
        if (filterByPfizer) {
          filtered_data <- filtered_data %>%
            filter(Pfizer == TRUE)
        }
        if (filterByPfizerChild) {
          filtered_data <- filtered_data %>%
            filter(Pfizer_child == TRUE)
        }
        if (filterByJanssen) {
          filtered_data <- filtered_data %>%
            filter(Janssen == TRUE)
        }
    }

    return (filtered_data)
  })

  # Get number of provider locations


  # Create map using Leaflet
  # see: https://rstudio.github.io/leaflet/
  output$vaccine_map <- renderLeaflet({
    leaflet(vaccine_data()) %>%
      addTiles() %>%
      # TODO marker should indicate availability
      addAwesomeMarkers(data = vaccine_data(), lat = ~latitude, lng = ~longitude,
                        popup = ~provider_popup, clusterOptions = markerClusterOptions(),
                        icon = awesomeIcons(icon = 'ion-medkit', iconColor = 'darkgreen',
                                            library = 'ion', markerColor = 'green'))
  })

  # Display table using DT
  # see: https://rstudio.github.io/DT/
  # see: https://clarewest.github.io/blog/post/making-tables-shiny/
  output$providers <- DT::renderDataTable({
    data_display <- vaccine_data() %>%
      relocate(name, city, state, zip, phone, insurance_accepted, walkins_accepted, Moderna, Pfizer, Pfizer_child, Janssen) %>%
      ungroup() %>%
      select(name, city, state, zip, phone, insurance_accepted, walkins_accepted, Moderna, Pfizer, Pfizer_child, Janssen)

    data_display #return the data to display
  },
  filter = 'bottom',
  rownames = FALSE,
  colnames = c("Vaccine Provider", "City", "State", "ZIP", "Phone No.",
               "Accepts Insurance", "Walk-Ins Allowed",
               "Moderna (18+) In Stock", "Pfizer (12+) In Stock",
               "Pfizer (5-11) In Stock", "J&J Janssen (18+) In Stock"),
  options = list(paging = TRUE,
                 pageLength = 5,
                 autoWidth = TRUE,
                 buttons = c('csv', 'excel'),
                 dom = 'Bfrtip'),
  extensions = 'Buttons',
  selection = 'single')

  # Create a downloadable report of our filtered data
  # see: https://shiny.rstudio.com/articles/generating-reports.html
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = str_c("vaccine_report", input$file_type_input),
    output_format <- ifelse(input$file_type_input == ".pdf", "pdf_document", "html_document"),
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)

      # Set up parameters to pass to Rmd document
      params <- list(state = input$state_input,
                     vaccine_type = input$vaccine_type_input,
                     insurance_accepted = input$insurance_input,
                     walkins_allowed = input$walkin_input,
                     file_type = input$file_type_input)

      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport,
                        output_file = file,
                        output_format = output_format,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
  })
}
