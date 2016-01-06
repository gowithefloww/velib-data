
mongo localhost:27017/velib ~/git/velib-data/ml/dispo/ml-dispo-trainingset-gen.js

mongoexport --db velib --collection ml_dispo_trainingset --type=csv --fields _id.datetime,_id.number,value --out ~/git/velib-data/ml/dispo/ml_dispo_trainingset.csv

head -n 10 ml_dispo_trainingset.csv