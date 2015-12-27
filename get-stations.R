# Import R MongoDB library
library(rmongodb)

library(stringi)

# Get stations data
stations <- read.csv2("http://opendata.paris.fr/explore/dataset/stations-velib-disponibilites-en-temps-reel/download/?format=csv&timezone=Europe/Berlin&use_labels_for_header=true", stringsAsFactors = FALSE)
stations <- stations[c("number","name","address","position","contract_name","banking")]

# Remove number from station name and nice uppercase 
stations$name <- as.character(data.frame(do.call('rbind', strsplit(as.character(stations$name)," - ",fixed=TRUE)))$X2)
stations$name <- tolower(stations$name)
stations$name <- stri_trans_totitle(stations$name)

# Parse latitude and longitude
stations$lat <- as.double(as.character(data.frame(do.call('rbind', strsplit(as.character(stations$position),", ",fixed=TRUE)))$X1))
stations$long <- as.double(as.character(data.frame(do.call('rbind', strsplit(as.character(stations$position),", ",fixed=TRUE)))$X2))

# Connect to MongoDB
mongo <- mongo.create()

# Check connection before doing anything
if(mongo.is.connected(mongo) == TRUE) {
  
  # Set the database name
  db <- "velib"
  
  # Set the collection name
  icoll <- paste(db, "stations", sep=".")
  
  # Convert dataframe to bson format
  bson <- mongo.bson.from.df(stations)
  
  # Drop the old collection
  mongo.drop(mongo,icoll)
  
  # Create documents
  mongo.insert.batch(mongo, icoll, bson)
}

# Close connection
mongo.destroy(mongo)
