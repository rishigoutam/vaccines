library(shinydashboard)
library(shinycssloaders)

header <- dashboardHeader(title = "COVID-19 Dashboard")

sidebar <- dashboardSidebar(collapsed = TRUE)

body <- dashboardBody(
  tabsetPanel(
    tabPanel("Map",
             withSpinner(leafletOutput("vaccine_map"), size = 2),
             selectInput("state_input", "State/Territory", choices = states_list,
                         selected = "", multiple = TRUE),
             numericInput("zip_input", "ZIP Code", value = ""),
             radioButtons("file_type_input", "Report File Type",
                          choices = c("PDF" = ".pdf", "HTML" = ".html"),
                          selected = ".pdf", inline = TRUE),
             checkboxGroupInput("vaccine_type_input", "Vaccine Type",
                                choiceNames = c("J&J Janssen (18+)", "Moderna (18+)", "Pfizer (12+)", "Pfizer (5-11)"),
                                choiceValues = c("Janssen", "Moderna", "Pfizer", "Pfizer_child"),
                                selected = c("Janssen", "Moderna", "Pfizer", "Pfizer_child")),
             downloadButton("report", "Generate report")),
    tabPanel("Data", DT::dataTableOutput("covid")),
    tabPanel("About", includeMarkdown("./TODO.Rmd"))
  )
)

dashboardPage(header, sidebar, body)
