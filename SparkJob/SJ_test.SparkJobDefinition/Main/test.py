################### INLINE LIBRARY INSTALL (runs on driver at job start) ########
import subprocess
import sys

subprocess.check_call([sys.executable, "-m", "pip", "install", "simple_salesforce"])

################### IMPORTING REQUIRED LIBRARIES ###############################
from simple_salesforce import Salesforce
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, LongType
from pyspark.sql.functions import current_timestamp, current_user

spark = SparkSession.builder.getOrCreate()

###################### CONNECTION ESTABLISHMENT WITH SALESFORCE #####################
sf = Salesforce(
    username="vndr_HariPrasath.Sundar@argonmedical.com",
    password="Salesforce@123",
    security_token="vBSIcern3CJXWYsnPMjhwxYP",
    domain="login",
)
print("Connected to Salesforce")


############### EXTRACTING THE LIST OF TABLES CONTAINING RECORDS (driver-side) #####
# Runs on the driver, same as your original script. Only the driver needs
# simple_salesforce since nothing here is distributed to executors.
results = []
objects = sf.describe()["sobjects"]

for obj in objects:
    object_name = obj["name"]
    if obj.get("queryable", False):
        try:
            count_result = sf.query(f"SELECT COUNT() FROM {object_name}")
            results.append((object_name, count_result["totalSize"], None))
            print(f"{object_name}: {count_result['totalSize']}")
        except Exception as e:
            results.append((object_name, None, str(e)))
            print(f"Skipped {object_name}: {str(e)}")

schema = StructType([
    StructField("Object_Name", StringType(), True),
    StructField("Row_Count", LongType(), True),
    StructField("Error", StringType(), True),
])

df = spark.createDataFrame(results, schema=schema)

# Split out failures so they don't silently vanish, mirroring the
# "Skipped {object}: {error}" prints in the original script.
success_df = df.filter(df.Error.isNull()).drop("Error").orderBy(df.Row_Count.desc())
skipped_df = df.filter(df.Error.isNotNull()).select("Object_Name", "Error")

print(f"Succeeded: {success_df.count()}, Skipped: {skipped_df.count()}")
skipped_df.show(truncate=False)


############### WRITE TO FABRIC LAKEHOUSE TABLE ####################################
final_df = (
    success_df
    .withColumn("LoadTimestamp", current_timestamp())
    .withColumn("LoadedBy", current_user())
)

final_df.write.mode("overwrite").format("delta").saveAsTable("salesforce_object_row_counts")

print("Write complete.")