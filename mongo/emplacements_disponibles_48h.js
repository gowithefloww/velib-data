// Sum the available bike stands for the last 48 hours

// Crontab for execution every 10 minutes:
// */10 * * * * mongo localhost:27017/velib ~/git/velib-data/mongo/emplacements_disponibles_48h.js

var map = function() {
  emit(this.datetime, this.available_bike_stands);
  
};
                   
var reduce = function(key, values) {
  return Array.sum(values);
};

db.dispo.mapReduce(
  map,
  reduce,
  {
    out:  "emplacements_disponibles_48h",
    query: {
      datetime: { $gt: new Date(ISODate().getTime() - (1000 * 60*60*24*3)) }
    }
  } 
);
