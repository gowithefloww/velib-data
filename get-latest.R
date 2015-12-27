# Read the Velib Open Data CSV and import it in MongoDB.

# Crontab for execution each minute:
# * * * * * R -f ~/git/velib-data/get-latest.R

# Be sure to create an index:
# db.dispo.createIndex( { datetime: -1 } )

# To export this collection
# mongoexport --db velib --collection dispo --type=csv --fields number,bonus,status,bike_stands,available_bike_stands,available_bikes,last_update,datetime --out ./dispo.csv

# Import R MongoDB library
library(rmongodb)

# Get velib data
data <- read.csv2("http://opendata.paris.fr/explore/dataset/stations-velib-disponibilites-en-temps-reel/download/?format=csv&timezone=Europe/Berlin&use_labels_for_header=true", stringsAsFactors = FALSE)

# Remove pointless variables
data$name <- NULL
data$address <- NULL
data$contract_name <- NULL
data$position <- NULL
data$banking <- NULL

# Format date
data$last_update <- strptime(data$last_update,format = "%FT%R:%S+01:00")

# Add a datetime variable with current time
data$datetime <- Sys.time()

# Connect to MongoDB
mongo <- mongo.create()

# Check connection before doing anything
if(mongo.is.connected(mongo) == TRUE) {
  
  # Set the database name
  db <- "velib"
  
  # Set the collection name
  icoll <- paste(db, "dispo", sep=".")
  
  # Convert dataframe to bson format
  bson <- mongo.bson.from.df(data)
  
  # Create documents
  mongo.insert.batch(mongo, icoll, bson)
}

# Close connection
mongo.destroy(mongo)