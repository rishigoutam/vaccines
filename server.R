# Vaccines Shiny app server

library(reshape2)
library(usmap)

function(input, output) {
  # Filter data by user input ---------------------------------------------
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

  # Reset filter(s) ------------------------------------------------------
  # Add an id so we can click the Filter badge and reset user selection(s)
  shinyjs::runjs("document.querySelectorAll('small')[1].id = 'clear'")
  shinyjs::onclick("clear", {
    shinyjs::reset("state_input")
    shinyjs::reset("vaccine_type_input")
    shinyjs::reset("insurance_input")
    shinyjs::reset("walkin_input")
    shinyjs::reset("format")
  })

  # Get number of provider locations --------------------------------------
  output$num_providers <- reactive({
    return (str_glue("{nrow(vaccine_data())} COVID-19 Vaccine Providers"))
  })

  # Create map using Leaflet ----------------------------------------------
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

  # Display table using DT -------------------------------------------------
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

  # Create a downloadable report of our filtered data -----------------------
  # see: https://shiny.rstudio.com/articles/generating-reports.html
  # see: https://shiny.rstudio.com/gallery/download-knitr-reports.html
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste('vaccine-report', sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
      ))
    },

    content = function(file) {
      src <- normalizePath('report.Rmd')

      params <- list(state = input$state_input,
                     vaccine_type = input$vaccine_type_input,
                     insurance_accepted = input$insurance_input,
                     walkins_allowed = input$walkin_input,
                     file_type = input$format,
                     df = vaccine_data())

      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd', overwrite = TRUE)

      library(rmarkdown)
      out <- render('report.Rmd', switch(input$format,
                                         PDF = pdf_document(),
                                         HTML = html_document(),
                                         Word = word_document()
                                         ),
                    params = params,
                    envir = new.env(parent = globalenv())
      )
      file.rename(out, file)
    }
  )

}
