library(shinydashboard)
library(shinycssloaders)

header <- dashboardHeader(title = "COVID-19 Dashboard")

sidebar <- dashboardSidebar(
  selectInput("state_input", "State/Territory", choices = states_list, multiple = TRUE),
  checkboxGroupInput("vaccine_type_input", "Vaccine in Stock",
                     choiceNames = c("J&J Janssen (18+)", "Moderna (18+)", "Pfizer (12+)", "Pfizer (5-11)"),
                     choiceValues = c("Janssen", "Moderna", "Pfizer", "Pfizer_child")),
  div(id = "preferences",
    checkboxInput("insurance_input", "Accepts Insurance", value = FALSE),
    checkboxInput("walkin_input", "Walk-Ins Allowed", value = FALSE))
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "vaccines.css")
  ),
  tabsetPanel(
    tabPanel("Map",
             withSpinner(leafletOutput("vaccine_map"), size = 1),

             # Report Generation
             radioButtons("file_type_input", "Report File Type",
                          choices = c("PDF" = ".pdf", "HTML" = ".html"),
                          selected = ".pdf", inline = TRUE),
             downloadButton("report", "Generate report")),
    tabPanel("Data", DT::dataTableOutput("providers")),
    tabPanel("About", includeMarkdown("./TODO.Rmd"))
  )
)

dashboardPage(header, sidebar, body)
