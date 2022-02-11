library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "COVID-19 Dashboard"),
  dashboardSidebar(collapsed = TRUE),
  dashboardBody(
    tabsetPanel(
      tabPanel("Map", leafletOutput("cfmap", height = 600)),
      tabPanel("Data", DT::dataTableOutput("covid")),
      tabPanel("About", includeMarkdown("../README.md"))
      )
    )
)
