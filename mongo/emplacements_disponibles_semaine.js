// Sum the available bike stands every hours for the last week

// Crontab for execution every hour:
// 0 * * * * mongo localhost:27017/velib ~/git/velib-data/mongo/emplacements_disponibles_semaine.js

var map = function() {
  emit(this.datetime.toJSON().substr(0, 13), this.available_bike_stands);
};
                   
var reduce = function(key, values) {
  return Array.avg(values);
};

db.dispo.mapReduce(
  map,
  reduce,
  {
    out:  "emplacements_disponibles_semaine",
    query: {
      datetime: { $gt: new Date(ISODate().getTime() - (1000 * 60*60*24*30)) }
    }
  } 
);
