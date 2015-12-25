# Inspiration: https://github.com/rstudio/shiny-examples/blob/master/063-superzip-example/ui.R

library(shiny)
library(leaflet)
library(rCharts)

shinyUI(fluidPage(navbarPage("Velo.paris", id="nav",
  
  tabPanel("Carte des stations",
    div(class="outer",
        tags$head(
          # Include our custom CSS
          includeCSS("styles.css")
          #includeScript("gomap.js")
        ),
        tags$head(tags$link(rel="shortcut icon", href="favicon.ico")),
        
    leafletOutput("mymap", width="100%", height="100%")
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