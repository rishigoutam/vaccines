library(shinydashboard)
library(shinycssloaders)


dashboardPage(
  dashboardHeader(title = "COVID-19 Dashboard"),
  dashboardSidebar(collapsed = TRUE),
  dashboardBody(
    tabsetPanel(
      tabPanel("Map",
               withSpinner(leafletOutput("cfmap", height = "600px"), size = 3),
               sliderInput("slider", "Slider", 1, 100, 50),
               selectInput("state_selection", "State", c("AK", "HI", "WA")),
               downloadButton("report", "Generate report")),
      tabPanel("Data", DT::dataTableOutput("covid")),
      tabPanel("About", includeMarkdown("./TODO.Rmd"))
      )
    )
)
