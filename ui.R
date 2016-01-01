# Inspiration: https://github.com/rstudio/shiny-examples/blob/master/063-superzip-example/ui.R

library(shiny)
library(leaflet)
library(rCharts)

shinyUI(fluidPage(navbarPage("Velo.paris", id="nav",
  
  tabPanel("Carte des stations",
           tags$head(tags$link(rel="icon", href="favicon.ico")),
    div(class="outer",
        tags$head(
          includeCSS("www/styles.css")
        ),
    leafletOutput("mymap", width="100%", height="100%"),
    
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                  width = 400, height = "auto",
                  
                  h3(textOutput("name"),align="center"),
                  showOutput("latest_dispo", "polycharts")
    )
    )
  ),
  tabPanel("Utilisation du service Vélib",mainPanel(align="center",
           showOutput("emplacements_disponibles_48h", "polycharts")
           #,showOutput("emplacements_disponibles_semaine", "polycharts")
  )),
  tabPanel("Approvisionnement des stations",
           div(class="outer",
               tags$head(
                 includeCSS("www/styles.css")
               ),
               leafletOutput("distribmap", width="100%", height="100%"),
               
               absolutePanel(id = "repartitionsliderpane", class = "panel panel-default", fixed = TRUE,
                             draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                             width = 400, height = "auto",align="center",
                             sliderInput("repartitionslider", "Heure",min=0, max=23, value=8)),
                             textOutput("Sélectionnez une heure de la journé grâce au sélecteur ci-dessus.
                                        La taille des cercles correspond au pourcentage moyen de vélos disponibles
                                        par rapport au nombre total d'emplacements par heure de la journée.")
           )
  ),
  tabPanel("À propos de ce site",
          includeMarkdown("about.md")
  )
  )
))