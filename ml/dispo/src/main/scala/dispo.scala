import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.types.{StructType, StructField, StringType, IntegerType, TimestampType,DateType};

import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.tree.configuration.Strategy
import org.apache.spark.mllib.util.MLUtils

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
			StructField("bikes", IntegerType, true)
			))
		
    val dispo = sqlContext.read
    			.format("com.databricks.spark.csv")
    			.option("header", "true")
    			.option("delimiter", ",")
			    .schema(customSchema)
			    .load("/home/paul/git/velib-data/ml_dispo_trainingset.csv")
		dispo.registerTempTable("dispo")
		dispo.show()
		
		//val dispo2 = sqlContext.sql("SELECT number, id_station, FROM_UNIXTIME(timestamp, 'YYYY-MM-dd') as majdate FROM majraw GROUP BY FROM_UNIXTIME(timestamp, 'YYYY-MM-dd'), id_carburant, id_station")
		//maj.registerTempTable("dispo2")
		//dispo2.show()

		// Cast timestamp to date
		//val maj = sqlContext.sql("SELECT id_carburant, id_station, AVG(prix) as meanprix, FROM_UNIXTIME(timestamp, 'YYYY-MM-dd') as majdate FROM majraw GROUP BY FROM_UNIXTIME(timestamp, 'YYYY-MM-dd'), id_carburant, id_station")
		//maj.registerTempTable("majmeandate")

		// Add -7d date column
		//val majng = sqlContext.sql("SELECT id_carburant, id_station, meanprix, cast(majdate as date) as majdate, DATE_SUB(cast(majdate as date), 7) as dm7 FROM majmeandate")
		//majng.registerTempTable("majmeandate")

		// Create stations table
		//val stations = sqlContext.read
    //			.format("com.databricks.spark.csv")
    //			.option("header", "true")
    //			.option("delimiter", ";")
		//	.option("inferSchema", "true")
		//	.load("/home/paul/data/stations.csv")
		//stations.registerTempTable("stations")

		// Create carb type table
		//val carb_type = sqlContext.read
    //			.format("com.databricks.spark.csv")
    //			.option("header", "true")
    //			.option("delimiter", ",")
		//	.option("inferSchema", "true")
		//	.load("/home/paul/data/carburant_type.csv")
		//carb_type.registerTempTable("carb_type")

		// Create brent price table wget www.quandl.com/api/v1/datasets/DOE/RBRTE.csv
		//val brent = sqlContext.read
    //			.format("com.databricks.spark.csv")
    //			.option("header", "true")
    //			.option("delimiter", ",")
		//	.option("inferSchema", "true")
		//	.load("/home/paul/data/RBRTE.csv")
		//brent.registerTempTable("brent")

		// Create DOW table wget http://www.quandl.com/api/v1/datasets/NASDAQOMX/NDX.csv
		//val dow = sqlContext.read
    //			.format("com.databricks.spark.csv")
    //			.option("header", "true")
    //			.option("delimiter", ",")
		//	.option("inferSchema", "true")
		//	.load("/home/paul/data/NDX.csv")
		//dow.registerTempTable("dow")

		// Join and get day - 7 price/ stations.id_station,marque/dow."Trade Date","Index Value"/brent."Date","Value"/
		//val majml = sqlContext.sql("""SELECT
		//					td.meanprix as dprice, tdm7.meanprix as dm7price,
		//					dbr.Value as dbrent, dm7br.Value as dm7br,
		//					do.`Index Value` as do, dm7do.`Index Value` as dm7do,
		//					st.marque, st.pop
		//				FROM majmeandate td
		//					JOIN majmeandate as tdm7 ON td.majdate = tdm7.dm7 AND td.id_carburant = tdm7.id_carburant AND td.id_station = tdm7.id_station
		//					JOIN brent dbr ON dbr.Date = td.majdate
		//					JOIN brent dm7br ON dm7br.Date = td.dm7
		//					JOIN stations st ON td.id_station = st.id_station
		//					JOIN carb_type ct ON ct.id = td.id_carburant
		//					JOIN dow do ON do.`Trade Date` = td.majdate
		//					JOIN dow dm7do ON dm7do.`Trade Date` = td.dm7
		//				WHERE ct.label = 'Gazole'
		//				""")
		//majml.registerTempTable("majml")

		// Convert rows to labeled poitns for MLLib
		// http://stackoverflow.com/questions/31638770/rdd-to-labeledpoint-conversion
		//majml.show
		//val ignored = List("dprice","marque","pop")
		//val featInd = majml.columns.diff(ignored).map(majml.columns.indexOf(_))
		//val targetInd = majml.columns.indexOf("dprice") 

		//val mlset = majml.rdd.map(r => LabeledPoint(
		//	r.getDouble(targetInd), // Get target value
		//	// Map feature indices to values
		//	Vectors.dense(featInd.map(r.getDouble(_)).toArray) 
		//))

		// https://databricks.com/blog/2015/01/21/random-forests-and-boosting-in-mllib.html
		// http://stanford.edu/~rezab/sparkworkshop/slides/xiangrui.pdf
		// http://blog.xebia.fr/2015/05/19/les-outils-de-la-data-science-spark-mllib-mise-en-pratique-22/
		// http://spark.apache.org/docs/latest/mllib-linear-methods.html#logistic-regression
		
		// Split data into training/test sets
		//val splits = mlset.randomSplit(Array(0.7, 0.3))
		//val (trainingData, testData) = (splits(0), splits(1))

		//val treeStrategy = Strategy.defaultStrategy("Classification")
		//val numTrees = 3 // Use more in practice.
		//val featureSubsetStrategy = "auto" // Let the algorithm choose.
		//val model = RandomForest.trainClassifier(trainingData, treeStrategy, numTrees, featureSubsetStrategy, seed = 12345)
		
		//val testErr = testData.map { point =>
  		//	val prediction = model.predict(point.features)
  		//	if (point.label == prediction) 1.0 else 0.0
		//	}.mean()
		//println("Test Error = " + testErr)
		//println("Learned Random Forest:n" + model.toDebugString)
	}
}
