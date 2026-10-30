from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split

spark = SparkSession.builder \
    .appName("Practica1-WordCount") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

df = spark.read.text("hdfs://192.168.56.10:9000/user/datos/archivo_prueba.txt").repartition(4)

palabras = df.select(explode(split(df.value, " ")).alias("palabra"))
conteo = palabras.groupBy("palabra").count()

conteo.write.mode("overwrite").csv("hdfs://192.168.56.10:9000/user/output/resultado_wordcount", header=True)
print("Trabajo completado correctamente")

spark.stop()
