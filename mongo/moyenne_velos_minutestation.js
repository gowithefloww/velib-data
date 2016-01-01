// Average number of bikes for each station each minute

// Crontab for execution every hour:
// 0 * * * * mongo localhost:27017/velib ~/git/velib-data/mongo/moyenne_velos_minutestation.js

var map = function() {
  emit({hour:this.datetime.getHours()
  ,number:this.number}, {valeur:this.available_bikes,stands:this.bike_stands});
};
                   
var reduce = function(key, values) {
  
  total = 0;
	count = 0;
	
	for (var i = 0;i<values.length; i++){
	  total += values[i].valeur;
	  count += 1;
	}
	
	totalstands = 0;
	countstands = 0;
	
	for (var j = 0;j<values.length; j++){
	  totalstands += values[j].stands;
	  countstands += 1;
	}
	
	return {valeur:total/count,stands:totalstands/countstands};
		
};

db.dispo.mapReduce(
  map,
  reduce,
  {
    out:      "moyenne_velos_minutestation",
    verbose:  true
  }
);





