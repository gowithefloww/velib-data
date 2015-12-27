# Inspiration:https://github.com/rstudio/shiny-examples/blob/master/063-superzip-example/server.R
# https://rstudio.github.io/leaflet/shiny.html
# https://rstudio.github.io/leaflet/basemaps.html
# Mongodoc: https://cran.r-project.org/web/packages/rmongodb/vignettes/rmongodb_introduction.html

library(shiny)
library(leaflet)
library(rmongodb)
library(rCharts)
library(reshape2)

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
  
  output$name <- renderText({ "Sélectionnez une station" })
  
  observeEvent(input$mymap_marker_click, {
    
    output$name <- renderText({ 
      stations$name[stations$number == input$mymap_marker_click$id]
    })
    
    output$latest_dispo <- renderChart2({
      
      available_bikes <- mongo.find.all(mongo,"velib.dispo",
                                        query = list('number' = input$mymap_marker_click$id, 'datetime' = list('$gte' = (Sys.time() - 86400))),
                                        fields = list("available_bikes" = 1,"datetime" = 1,"available_bike_stands" = 1,"bike_stands" = 1))
      available_bikes <- data.frame(matrix(unlist(available_bikes), nrow=length(available_bikes), byrow=T))
      names(available_bikes) <- c("id","bike_stands","available_bike_stands","available_bikes","date")
      available_bikes$id <- NULL
      available_bikes$available_bikes <- as.integer(as.character(available_bikes$available_bikes))
      available_bikes$available_bike_stands <- as.integer(as.character(available_bikes$available_bike_stands))
      available_bikes$bike_stands <- as.integer(as.character(available_bikes$bike_stands))
      available_bikes$date <- as.POSIXct(as.integer(as.character(available_bikes$date)), origin="1970-01-01")
      available_bikes <- melt(available_bikes,id=("date"))
      available_bikes$heure <- strftime(available_bikes$date,"%H:%M")
      available_bikes$variable <- as.character(available_bikes$variable)
      available_bikes$variable[available_bikes$variable == "bike_stands"] <- "Emplacements"
      available_bikes$variable[available_bikes$variable == "available_bikes"] <- "Vélos disponibles"
      available_bikes$variable[available_bikes$variable == "available_bike_stands"] <- "Places libres"
      names(available_bikes)[names(available_bikes)=="variable"] <- "Disponibilités"
      
      p1 <- rPlot(y="value", x=list(var="heure", sort="date"),data=available_bikes,type = 'line',color="Disponibilités",size=list(const=2))
      p1$guides(y = list(title = "",min = min(available_bikes$value) - 1, max= max(available_bikes$value) + 1))
      p1$guides(x = list(title = ""))
      p1$addParams(width = 360, height = 300,title = "Dernières 24 heures")
      p1$set(legendPosition = "bottom")
      p1$set(legendName = "bottom")
      p1
    })
    
    
  })
  
  points <- eventReactive(input$recalc, {
    stations[c("lat","long")]
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Hydda.Full",
                       options = providerTileOptions(noWrap = TRUE)
                       ) %>% setView(lng = 2.3572111, lat = 48.8581874, zoom = 15) %>% 
      addMarkers(data = points(),layerId = stations$number)
  })
  
}
