# Inspiration: https://github.com/rstudio/shiny-examples/blob/master/063-superzip-example/ui.R

library(shiny)
library(leaflet)
library(rCharts)

shinyUI(fluidPage(navbarPage("Velo.paris", id="nav",
  
  tabPanel("Carte des stations",
    div(class="outer",
        tags$head(
          includeCSS("styles.css")
        ),
        #tags$head(tags$link(rel="shortcut icon", href="favicon.ico")),
        
    leafletOutput("mymap", width="100%", height="100%"),
    
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                  width = 400, height = "auto",
                  
                  h3(textOutput("name")),
                  showOutput("latest_dispo", "polycharts")
                  #p("Dans 10 minutes il y aura à cette station:"),
                  #p("15 places libres et 33 vélos disponibles."),
                  #p("Dans 30 minutes:"),
                  #p("33 places libres et 15 vélos disponibles."),
                  #p("Dans 1 heure:"),
                  #p("38 places libres et 10 vélos disponibles.")
    )
    
    #,p(),
    #textOutput("name"),
    #showOutput("dataplot", "polycharts")
    )
  ),
  tabPanel("Utilisation du service Vélib"
  ),
  tabPanel("À propos de ce site"
  )
  )
))