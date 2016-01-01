sbt package
/home/paul/spark-1.5.1/bin/spark-submit --packages com.databricks:spark-csv_2.10:1.2.0 --class "Dispo" --master local[4] target/scala-2.10/dispo_2.10-1.0.jar
