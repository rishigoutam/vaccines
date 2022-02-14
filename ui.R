library(shinydashboard)
library(shinycssloaders)

# Header ------------------------------------------------------------------

header <- dashboardHeader(title = "COVID-19 Dashboard")

# Sidebar -----------------------------------------------------------------

sidebar <- dashboardSidebar(
  sidebarMenu(
    # Setting id makes input$tabs give the tabName of currently-selected tab
    id = "tabs",
    menuItem("About", tabName = "About", icon = icon("info-circle"), selected = TRUE),
    menuItem("Vaccine Dashboard", icon = icon('dashboard'), startExpanded = TRUE,
      menuSubItem("Providers Map", tabName = "Map", icon = icon("map")),
      menuSubItem("Data Table", tabName = "Data", icon = icon("table"))
    ),
    menuItem("Future Development", tabName = "FutureDev", icon = icon("code")),
    menuItem("://rishigoutam", icon = icon("github"), badgeLabel = "open",
             href = "https://www.github.com/rishigoutam/vaccines", newtab = TRUE),
    menuItem("") # spacing
  ),

  # Show filters for the 'Maps' and 'Data' tabs only
  conditionalPanel(condition = "input.tabs == 'Map' || input.tabs == 'Data'",
    menuItem("Filters", icon = icon("filter"), badgeLabel = "clear"),
    selectInput("state_input", "State/Territory", choices = states_list, multiple = TRUE),
    checkboxGroupInput("vaccine_type_input", "Vaccine in Stock",
                       choiceNames = c("J&J Janssen (18+)", "Moderna (18+)", "Pfizer (12+)", "Pfizer (5-11)"),
                       choiceValues = c("Janssen", "Moderna", "Pfizer", "Pfizer_child")),
    checkboxGroupInput("preferences_title", "Provider Preferences"),
    div(id = "preferences",
        checkboxInput("insurance_input", "Accepts Insurance", value = FALSE),
        checkboxInput("walkin_input", "Walk-Ins Allowed", value = FALSE)),

    # Report Generation
    radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                 inline = TRUE),
    div(id = "download", downloadButton("downloadReport"))
  )
)

# Body --------------------------------------------------------------------

body <- dashboardBody(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "vaccines.css"),
    tags$style("@import url(https://use.fontawesome.com/releases/v6.0.0/css/all.css);"),
  ),

  tabItems(
    tabItem("Map",
            textOutput("num_providers"),
            withSpinner(leafletOutput("vaccine_map"), type = 7)),
    tabItem("Data",
            withSpinner(DT::dataTableOutput("providers"))),
    tabItem("About", includeMarkdown("./project_submission.md")),
    tabItem("FutureDev", includeMarkdown("./TODO.Rmd"))
  )
)

# Page --------------------------------------------------------------------

dashboardPage(header, sidebar, body, skin = 'green')
