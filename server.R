# Inspiration:https://github.com/rstudio/shiny-examples/blob/master/063-superzip-example/server.R
# https://rstudio.github.io/leaflet/shiny.html
# https://rstudio.github.io/leaflet/basemaps.html
# Mongodoc: https://cran.r-project.org/web/packages/rmongodb/vignettes/rmongodb_introduction.html

library(shiny)
library(leaflet)
library(rmongodb)
library(rCharts)

# Import stations list from MongoDB
mongo <- mongo.create()
stations <- mongo.find.all(mongo,"velib.stations")
stations <- data.frame(matrix(unlist(stations), nrow=length(stations), byrow=T))
names(stations) <- c("id","number","name","address","position","contract","banking", "lat","long")
stations$long <- as.double(as.character(stations$long))
stations$lat <- as.double(as.character(stations$lat))
stations$number <- as.integer(as.character(stations$number))
stations$name <- as.character(stations$name)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

server <- function(input, output, session) {
  
  observeEvent(input$mymap_marker_click, {
    
    
    output$name <- renderText({ 
      stations$name[stations$number == input$mymap_marker_click$id]
    })
    
    output$dataplot <- renderChart2({
      available_bikes <- mongo.find.all(mongo,"velib.dispo", query = list("number" = input$mymap_marker_click$id),fields = list("available_bikes" = 1,"datetime" = 1))
      available_bikes <- data.frame(matrix(unlist(available_bikes), nrow=length(available_bikes), byrow=T))
      p1 <- rPlot(X2 ~ X3,data=available_bikes,type = 'line')
      return(p1)
    })
    
    
  })
  
  points <- eventReactive(input$recalc, {
    stations[c("lat","long")]
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron",
                       options = providerTileOptions(noWrap = TRUE)
                       ) %>% setView(lng = 2.3572111, lat = 48.8581874, zoom = 15) %>% 
      addMarkers(data = points(),layerId = stations$number)
  })
  
}
