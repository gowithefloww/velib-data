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
stations <- data.frame(t(sapply(stations,c)))
#stations <- data.frame(matrix(unlist(stations), nrow=length(stations), byrow=T))
names(stations) <- c("id","number","name","address","position","contract","banking", "lat","long","commune","code_postal","dep")
stations$long <- as.double(as.character(stations$long))
stations$lat <- as.double(as.character(stations$lat))
stations$number <- as.integer(as.character(stations$number))
stations$name <- as.character(stations$name)

mvms <- mongo.find.all(mongo,"velib.moyenne_velos_minutestation")
mvms <- data.frame(t(sapply(mvms,c)))
mvms$number <- sapply(mvms$X_id,function(x) x$number)
mvms$hour <- sapply(mvms$X_id,function(x) x$hour)
mvms$bikes <- sapply(mvms$value,function(x) x$valeur)
mvms$stands <- sapply(mvms$value,function(x) x$stands)
mvms$X_id <- NULL
mvms$value <- NULL
mvms$prc_full <- mvms$bikes*100/mvms$stands
mvms <- merge(stations,mvms)

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
      available_bikes$variable[available_bikes$variable == "available_bikes"] <- "Vélos"
      available_bikes$variable[available_bikes$variable == "available_bike_stands"] <- "Places libres"
      names(available_bikes)[names(available_bikes)=="variable"] <- "Disponibilités"
      available_bikes$numrow <- nrow(available_bikes)-1:nrow(available_bikes)
      
      p1 <- rPlot(y="value", x=list(var="heure", sort="numrow"),data=available_bikes,type = 'line',color="Disponibilités",size=list(const=2))
      p1$guides(y = list(title = "",min = min(available_bikes$value) - 1, max= max(available_bikes$value) + 1))
      p1$guides(x = list(title = ""))
      p1$addParams(width = 360, height = 300,title = "Dernières 24 heures")
      p1$set(legendPosition = "bottom")
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
  
  output$emplacements_disponibles_48h <- renderChart2({
    service <- mongo.find.all(mongo,"velib.emplacements_disponibles_48h")
    service <- data.frame(matrix(unlist(service), nrow=length(service), byrow=T))
    names(service) <- c("datetime","available_stands")
    service$datetime <- as.POSIXct(service$datetime, origin="1970-01-01")
    service$heure <- strftime(service$datetime,"%A %d %H:%M")
    
    service$numrow <- 1:nrow(service)
    rPlot(y="available_stands", x="numrow",data=service,type ='line')
    #p1$guides(x = list(title = ""))
    
    p1 <- rPlot(y="available_stands", x="numrow",data=service,type = 'line',size=list(const=1))
    p1$addParams(title = "Emplacements disponibles ces dernières 72 heures sur l'ensemble du réseau")
    p1$guides(x = list(title = "",labels =service$heure))
    p1$guides(y = list(title = "",
                       min =  min(service$available_stands) - (max(service$available_stands)/99),
                       max = max(service$available_stands) + (max(service$available_stands)/99)))
    p1
  })
  
  output$emplacements_disponibles_semaine <- renderChart2({
    vds <- mongo.find.all(mongo,"velib.emplacements_disponibles_semaine")
    vds <- data.frame(matrix(unlist(vds), nrow=length(vds), byrow=T))
    names(vds) <- c("datetime","emplacements_disponibles_semaine")
    vds$emplacements_disponibles_semaine <- as.double(as.character(vds$emplacements_disponibles_semaine))*dim(stations)[[1]]
    vds$datetime2 <- substr(as.character(vds$datetime), 0, 10)
    
    p1 <- rPlot(y="emplacements_disponibles_semaine", x=list(var="datetime", sort="datetime2"),data=vds,type = 'line',size=list(const=2))
    p1$addParams(title = "Nombre d'emplacements disponibles la semaine passée")
    p1$guides(x = list(title = ""))
    p1$guides(y = list(title = "",
              min =  min(vds[c("emplacements_disponibles_semaine")]) - (max(vds[c("emplacements_disponibles_semaine")])/20),
              max = max(vds[c("emplacements_disponibles_semaine")]) + (max(vds[c("emplacements_disponibles_semaine")])/20)))
    p1
    })
  
  output$distribmap <- renderLeaflet({
    
    points2 <- eventReactive(input$recalc, {
      mvms[which(mvms$hour == input$repartitionslider),][c("lat","long")]
    }, ignoreNULL = FALSE)
      
    leaflet() %>%
      addProviderTiles("Stamen.Toner",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>% setView(lng = 2.3572111, lat = 48.8581874, zoom = 13) %>% 
      addCircleMarkers(
        radius = mvms[which(mvms$hour == input$repartitionslider),]$prc_full/7,
        color = "lightblue",
        stroke = FALSE, fillOpacity = 0.7,
        data = points2()
      )
  })
}





