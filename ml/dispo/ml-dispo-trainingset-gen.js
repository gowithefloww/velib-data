//ml-dispo-trainingset-gen.js

var map = function() {
  emit({
    datetime: ((this.datetime.getTime() - (this.datetime.getTime() % (60*1000)))/1000).toString(),
    number: this.number
  },
  this.available_bikes);
};

var reduce = function(key, values) {
  return values.available_bikes;
};

db.dispo.mapReduce(
  map,
  reduce,
  {
    out:  "ml_dispo_trainingset",
    query: {
      status : "OPEN"
    }
  } 
);