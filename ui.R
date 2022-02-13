library(shinydashboard)
library(shinycssloaders)

header <- dashboardHeader(title = "COVID-19 Dashboard")

sidebar <- dashboardSidebar(
  sidebarMenu(
    # Setting id makes input$tabs give the tabName of currently-selected tab
    id = "tabs",
    menuItem("About", tabName = "About", icon = icon("info-circle")),
    menuItem("Vaccine Dashboard", icon = icon('dashboard'), startExpanded = TRUE,
      menuSubItem("Providers Map", tabName = "Map", icon = icon("map")),
      menuSubItem("Data Table", tabName = "Data", icon = icon("table"))
    ),
    menuItem("Future Development", tabName = "FutureDev", icon = icon("code")),
    menuItem("://rishigoutam", icon = icon("github"), badgeLabel = "open",
             href = "https://www.github.com/rishigoutam/vaccines", newtab = TRUE),
    menuItem("")
  ),

  # Show filters for the 'Maps' and 'Data' tabs only
  conditionalPanel(condition = "input.tabs == 'Map' || input.tabs == 'Data'",
    menuItem("Filters", icon = icon("filter")),
    selectInput("state_input", "State/Territory", choices = states_list, multiple = TRUE),
    checkboxGroupInput("vaccine_type_input", "Vaccine in Stock",
                       choiceNames = c("J&J Janssen (18+)", "Moderna (18+)", "Pfizer (12+)", "Pfizer (5-11)"),
                       choiceValues = c("Janssen", "Moderna", "Pfizer", "Pfizer_child")),
    checkboxGroupInput("preferences_title", "Provider Preferences"),
    div(id = "preferences",
        checkboxInput("insurance_input", "Accepts Insurance", value = FALSE),
        checkboxInput("walkin_input", "Walk-Ins Allowed", value = FALSE))
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "vaccines.css"),
    tags$style("@import url(https://use.fontawesome.com/releases/v6.0.0/css/all.css);"),
  ),

  tabItems(
    tabItem("Map",
             textOutput("num_providers"),
             withSpinner(leafletOutput("vaccine_map"), type = 7),

             # Report Generation
             radioButtons("file_type_input", "Report File Type",
                          choices = c("PDF" = ".pdf", "HTML" = ".html"),
                          selected = ".pdf", inline = TRUE),
             downloadButton("report", "Generate report")),
    tabItem("Data",
            withSpinner(DT::dataTableOutput("providers"))),
    tabItem("About", includeMarkdown("./README.md")),
    tabItem("FutureDev", includeMarkdown("./TODO.Rmd"))
  )
)

dashboardPage(header, sidebar, body, skin = 'green')
