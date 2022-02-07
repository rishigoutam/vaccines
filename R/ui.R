navbarPage("TODO TITLE", id="main",
           tabPanel("Map", leafletOutput("cfmap", height=500)),
           tabPanel("Data", DT::dataTableOutput("covid")),
           tabPanel("README", includeMarkdown("../README.md")))
