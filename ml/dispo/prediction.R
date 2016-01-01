# http://tebros.com/2011/07/using-mongodb-mapreduce-to-join-2-collections/

options(scipen=999) # Disable scientific notation
dispo <- read.csv("ml_dispo_trainingset.csv")
names(dispo) <- c("ts","station","bikes")
dispo$ts <- dispo$ts/1000
dispo$ts <- as.integer(dispo$ts)

dispohm24 <- dispo
dispohm24$ts <- dispohm24$ts - (60*60*24)
dispohm24$ts <- as.integer(dispohm24$ts)

library(sqldf)
train <- sqldf("SELECT d.ts,d.station,d.bikes,
                dhm24.bikes
                FROM dispo d
                JOIN dispohm24 dhm24 ON dhm24.ts = d.ts
                ",drv="SQLite")

train <- sqldf("SELECT d.ts,d.station,d.bikes
                FROM dispo d
                JOIN dispohm24 dhm24 ON dispohm24.ts = dispo.ts
                ",drv="SQLite")

#train <- merge(x = dispohm24,y = dispo )


