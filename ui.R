library(shinydashboard)
library(shinycssloaders)

dashboardPage(
  dashboardHeader(title = "COVID-19 Dashboard"),
  dashboardSidebar(collapsed = TRUE),
  dashboardBody(
    tabsetPanel(
      tabPanel("Map", withSpinner(leafletOutput("cfmap", height = "600px"), size = 3)),
      tabPanel("Data", DT::dataTableOutput("covid")),
      tabPanel("About", includeMarkdown("./README.md"))
      )
    )
)
