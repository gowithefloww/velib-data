import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.types.{StructType, StructField, StringType, IntegerType, TimestampType,DateType, DoubleType};

import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.feature.StandardScaler

object Dispo {
	def main(args: Array[String]) {
		// http://spark.apache.org/docs/latest/sql-programming-guide.html
		val conf = new SparkConf().setAppName("Prediction Disponibilite")
        	conf.set("spark.master","spark://ns3008884.ip-151-80-46.eu:7077")

		// Init contexts
		val sc = new SparkContext(conf)
		val sqlContext = new SQLContext(sc)

    // Load df
		// https://github.com/databricks/spark-csv
		val customSchema = StructType(Array(
			StructField("ts", IntegerType, true),
		  StructField("number", IntegerType, true),
			StructField("bikes", DoubleType, true)
			))
		
    val dispo = sqlContext.read
    			.format("com.databricks.spark.csv")
    			.option("header", "true")
    			.option("delimiter", ",")
			    .schema(customSchema)
			    .load("/home/paul/git/velib-data/ml/dispo/ml_dispo_trainingset.csv")
		dispo.registerTempTable("dispo")
		dispo.show()
		
		val train = sqlContext.sql("""
		                            SELECT
		                            d.bikes as bikes,
		                            d.number,
		                            mp15.bikes as mp15,
		                            //mp30.bikes as mp30,
		                            //mp45.bikes as mp45,
		                            //mp60.bikes as mp60,
		                            
		                            mm30.bikes as mm30,
		                            hm1.bikes as hm1,
		                            //hm2.bikes as hm2,
		                            hm24.bikes as hm24,
		                            hm25.bikes as hm25
		                            
		                            FROM dispo d
		                            
		                            JOIN (SELECT ts + (60*15) as ts, number, bikes FROM dispo) mp15 ON mp15.ts = d.ts AND mp15.number = d.number
		                            //JOIN (SELECT ts + (60*30) as ts, number, bikes FROM dispo) mp30 ON mp30.ts = d.ts AND mp30.number = d.number
		                            //JOIN (SELECT ts + (60*45) as ts, number, bikes FROM dispo) mp45 ON mp45.ts = d.ts AND mp45.number = d.number
		                            //JOIN (SELECT ts + (60*60) as ts, number, bikes FROM dispo) mp60 ON mp60.ts = d.ts AND mp60.number = d.number
		                            
		                            JOIN (SELECT ts - (60*30) as ts, number, bikes FROM dispo) mm30 ON mm30.ts = d.ts AND mm30.number = d.number
		                            JOIN (SELECT ts - (60*60) as ts, number, bikes FROM dispo) hm1 ON hm1.ts = d.ts AND hm1.number = d.number
		                            //JOIN (SELECT ts - (60*60*2) as ts, number, bikes FROM dispo) hm2 ON hm2.ts = d.ts AND hm2.number = d.number
		                            JOIN (SELECT ts - (60*60*24) as ts, number, bikes FROM dispo) hm24 ON hm24.ts = d.ts AND hm24.number = d.number
		                            JOIN (SELECT ts - (60*60*25) as ts, number, bikes FROM dispo) hm25 ON hm25.ts = d.ts AND hm25.number = d.number
		                            
                                """) 
		
		train.write
		  .format("com.databricks.spark.csv")
      .option("header", "true")
      .save("data")
		
	}
}
