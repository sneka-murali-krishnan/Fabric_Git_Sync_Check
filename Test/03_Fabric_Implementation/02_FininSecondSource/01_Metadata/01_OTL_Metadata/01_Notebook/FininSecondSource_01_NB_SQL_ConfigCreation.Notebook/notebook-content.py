# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {}
# META }

# MARKDOWN ********************

# ###### This notebook extracts metadata from SQL Server, generates dynamic SQL queries for each table, and enriches the data with schema and table transformations for ETL purposes. It then assigns unique IDs, applies necessary transformations, and loads the processed metadata into a centralized configuration table for downstream processing


# PARAMETERS CELL ********************

ConfigSchemaName = 'Config_FininSecondSource'

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### IMPORT  REQUIRED PACKAGES ###################################################
from pyspark.sql import SparkSession
from pyspark.sql import DataFrame
from pyspark.sql.functions import (
col, lit, concat, when, trim, collect_list,collect_set, row_number, to_date,date_format,
col, concat, lit, to_timestamp, date_format, to_date, coalesce,concat_ws, md5,struct,
udf , concat, to_timestamp,count, when ,  sum as _sum)
from pyspark.sql.window import Window
from datetime import datetime, timezone, timedelta
from delta.tables import DeltaTable
import pandas as pd
from com.microsoft.spark.fabric import Constants
import com.microsoft.spark.fabric
from com.microsoft.spark.fabric.Constants import Constants
from pyspark.sql.types import (
    DoubleType, IntegerType, BooleanType, StringType,StructField,ArrayType,
    BinaryType, TimestampType, DateType, LongType, StructType
)
import concurrent.futures
import pytz
import traceback
import os
import json

from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, lit, concat, collect_list, row_number
)
from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType
)
from pyspark.sql.window import Window   

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### SPARK SESSION ###################################################
spark = SparkSession.builder \
    .appName("MetaData") \
    .config("spark.sql.parquet.int96RebaseModeInRead", "CORRECTED") \
    .config("spark.sql.parquet.int96RebaseModeInWrite", "CORRECTED") \
    .config("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED") \
    .config("spark.sql.parquet.datetimeRebaseModeInRead", "CORRECTED") \
    .config("spark.sql.legacy.parquet.datetimeRebaseModeInWrite", "CORRECTED") \
    .config("spark.sql.legacy.parquet.datetimeRebaseModeInRead", "CORRECTED") \
    .config("spark.sql.caseSensitive", "true") \
    .config("spark.sql.legacy.timeParserPolicy", "LEGACY") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .getOrCreate()


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### LOADING METADATA ####################################################
try:
    InformationSchema= f"SELECT * FROM {ConfigSchemaName}.SourceInformationSchema"
    InformationSchema_df= spark.read.option(Constants.DatabaseName, "WH_MetaData").synapsesql(InformationSchema)
except Exception as e:
    print(e)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### LOADING KEY CONSTRAINTS ################################################### 
try:
    KeyConstraint = f"SELECT * FROM {ConfigSchemaName}.KeyConstraintConfig"

    KeyConstraint_df = spark.read.option(
        Constants.DatabaseName,
        "WH_MetaData"
    ).synapsesql(KeyConstraint)

    #KeyConstraint_df = KeyConstraint_df.filter(   col("OWNER") == 'HOSPITAL' )

except Exception as e:
    print("Error loading Key Constraints:", e)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### LOADING PRIMARY KEY  ################################################### 

try:
    PrimaryKey = f"SELECT * FROM {ConfigSchemaName}.PrimaryKeyConfig"

    PrimaryKey_df = spark.read.option(
        Constants.DatabaseName,
        "WH_MetaData"
    ).synapsesql(PrimaryKey)

    #PrimaryKey_df = PrimaryKey_df.filter(
       # col("OWNER") == 'HOSPITAL'
    #)

except Exception as e:
    print("Error loading Key Constraints:", e)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### 4. FILTER AND GROUP ###################################################


InformationSchema_deduped = InformationSchema_df.dropDuplicates(
    ["TABLE_SCHEMA", "TABLE_NAME", "COLUMN_NAME"]
)

grouped_df = InformationSchema_deduped.groupBy("TABLE_SCHEMA", "TABLE_NAME").agg(
    collect_list(struct("COLUMN_NAME", "DATA_TYPE")).alias("columns")
)

pk_df = PrimaryKey_df.groupBy("TABLE_SCHEMA", "TABLE_NAME").agg(
    collect_set("COLUMN_NAME").alias("PrimaryKey")
)

# Join AFTER grouping — this is safe, both sides are already aggregated
final_with_pk = grouped_df.join(
    pk_df,
    ["TABLE_SCHEMA", "TABLE_NAME"],
    "left"
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import collect_list

pk_df = PrimaryKey_df.groupBy("TABLE_SCHEMA", "TABLE_NAME").agg(
    collect_set("COLUMN_NAME").alias("PrimaryKey")
)

final_with_pk = grouped_df.join(
    pk_df,
    ["TABLE_SCHEMA", "TABLE_NAME"],
    "left"
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### 5. GENERATING SOURCE QUERY ###################################################

def get_source_type(config_schema_name: str) -> str:

    name = config_schema_name.lower()
    if "sqlserver" in name or "sql" in name:
        return "sqlserver"
    elif "oracle" in name:
        return "oracle"
    elif "postgres" in name:
        return "postgres"
    elif "mysql" in name:
        return "mysql"
    else:
        return "sqlserver"   


def quote_identifier(identifier: str, source_type: str) -> str:

    if source_type == "sqlserver":
        return f"[{identifier}]"
    elif source_type in ("oracle", "postgres"):
        return f'"{identifier}"'
    elif source_type == "mysql":
        return f"`{identifier}`"
    else:
        return f"[{identifier}]"   # fallback


def generate_source_query(table_name: str, columns: list, schema_name: str,
                          config_schema_name: str = None) -> str:
    source_type = get_source_type(config_schema_name or "")

    seen = set()
    unique_columns = []
    for col in columns:
        col_name = col["COLUMN_NAME"]
        if col_name not in seen:
            seen.add(col_name)
            unique_columns.append(col)


    quoted_columns = [
        quote_identifier(col["COLUMN_NAME"], source_type)
        for col in unique_columns
    ]

    quoted_schema = quote_identifier(schema_name, source_type)
    quoted_table  = quote_identifier(table_name,  source_type)

    return f"SELECT {', '.join(quoted_columns)} FROM {quoted_schema}.{quoted_table}"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### 6. COLLECTING METADATA ###################################################
metadata = []

for row in final_with_pk.collect():
    table_name  = row["TABLE_NAME"]
    schema_name = row["TABLE_SCHEMA"]
    columns     = row["columns"]

    source_query = generate_source_query(
        table_name, columns, schema_name,
        config_schema_name=ConfigSchemaName  
    )

    primary_key = ",".join(row["PrimaryKey"]) if row["PrimaryKey"] else None

    metadata.append((
        table_name,
        schema_name,
        source_query,
        primary_key
    ))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

try:
    Configdf=f"SELECT Id  FROM {ConfigSchemaName}.Config_InformationSchema"
    max_id= spark.read.option(Constants.DatabaseName, "WH_MetaData").synapsesql(Configdf)
    max_id = max_id.agg({"Id": "max"}).collect()[0]["max(Id)"]
except Exception as e:
    max_id = 0
    

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

schema = StructType([
    StructField("SourceTableName", StringType(), True),
    StructField("SourceSchemaName", StringType(), True),
    StructField("SourceQuery", StringType(), True),
    StructField("PrimaryKey", StringType(), True)
])
 
 
df = spark.createDataFrame(metadata, schema=schema)
final_df = spark.createDataFrame(metadata, schema=schema)
 

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### 8.COLUMN SELECTION AND MODIFICATIONS ###################################################
from pyspark.sql.functions import lit, concat, row_number, col
from pyspark.sql.window import Window

window_spec = Window.orderBy(lit(1))

# Update the DataFrame with the new Id starting from 294
df = df.withColumn("Id", row_number().over(window_spec).cast(IntegerType())) \
    .withColumn("BronzeSchemaName",  col("SourceSchemaName")) \
    .withColumn("BronzeTableName", col("SourceTableName")) \
    .withColumn("SilverSchemaName",  col("SourceSchemaName")) \
    .withColumn("SilverTableName", col("SourceTableName")) \
    .withColumn("IsActive", lit("1")) \
    .withColumn("LoadType", lit("Table")) 


selected_df = df.select(
    "Id", "SourceTableName", "SourceSchemaName", "BronzeSchemaName", 
    "BronzeTableName", "SilverSchemaName", "SilverTableName", 
    "SourceQuery", "IsActive", "LoadType","PrimaryKey"
)

selected_df = selected_df.withColumn(
    "CreatedBy",lit("Service Principle")
)
createdtime = datetime.now(timezone.utc)
selected_df = selected_df.withColumn(
    "CreatedDate",lit(createdtime).cast(StringType())
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### 9. DEFINING STRUCTURE OF THE DATAFRAME ###################################################
 
from pyspark.sql.types import StructType, StructField, IntegerType, StringType
new_schema = StructType([
    StructField("Id", IntegerType(), True),
    StructField("SourceTableName", StringType(), True),
    StructField("SourceSchemaName", StringType(), True),
    StructField("BronzeSchemaName", StringType(), True),
    StructField("BronzeTableName", StringType(), True),
    StructField("SilverSchemaName", StringType(), True),
    StructField("SilverTableName", StringType(), True),
    StructField("SourceQuery", StringType(), True),
    StructField("IsActive", StringType(), True),
    StructField("LoadType", StringType(), True), 
    StructField("PrimaryKey", StringType(), True),
])

#df = spark.createDataFrame(df.rdd, new_schema)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### 9.LOADING THE METADATA DETAILS ###################################################
LoadTable = f"WH_MetaData.{ConfigSchemaName}.OneTimeConfigETL"
selected_df.write.mode("append").synapsesql(LoadTable)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### N. VIEW DISCOVERY (INFORMATION_SCHEMA.VIEWS) ###################################################
try:
    ViewInformationSchema = f"SELECT * FROM {ConfigSchemaName}.SourceInformationViews"
    ViewInformationSchema_df = spark.read.option(Constants.DatabaseName, "WH_MetaData").synapsesql(ViewInformationSchema)
except Exception as e:
    print(e)
    ViewInformationSchema_df = None

if ViewInformationSchema_df is not None:
    from pyspark.sql.functions import lit, concat, row_number, col
    from pyspark.sql.window import Window
    from pyspark.sql.types import StructType, StructField, IntegerType, StringType

    views_filtered_df = ViewInformationSchema_df.filter(col("TABLE_SCHEMA") != "sys")
    existing_max_id = selected_df.agg({"Id": "max"}).collect()[0][0] or 0
    view_window_spec = Window.orderBy(lit(1))

    views_df = views_filtered_df.select(
        col("TABLE_NAME").alias("SourceTableName"),
        col("TABLE_SCHEMA").alias("SourceSchemaName"),
    )
    views_df = views_df.withColumn(
        "SourceQuery",
        concat(lit("SELECT * FROM ["), col("SourceSchemaName"), lit("].["), col("SourceTableName"), lit("]")),
    )
    views_df = views_df.withColumn("Id", (row_number().over(view_window_spec) + lit(existing_max_id)).cast(IntegerType())) \
        .withColumn("BronzeSchemaName", col("SourceSchemaName")) \
        .withColumn("BronzeTableName", col("SourceTableName")) \
        .withColumn("SilverSchemaName", col("SourceSchemaName")) \
        .withColumn("SilverTableName", col("SourceTableName")) \
        .withColumn("IsActive", lit("0")) \
        .withColumn("LoadType", lit("View")) \
        .withColumn("PrimaryKey", lit(None).cast(StringType())) \
        .withColumn("CreatedBy", lit("Service Principle"))
    views_df = views_df.withColumn("CreatedDate", lit(createdtime).cast(StringType()))

    selected_views_df = views_df.select(
        "Id", "SourceTableName", "SourceSchemaName", "BronzeSchemaName",
        "BronzeTableName", "SilverSchemaName", "SilverTableName",
        "SourceQuery", "IsActive", "LoadType", "PrimaryKey",
        "CreatedBy", "CreatedDate",
    )
else:
    selected_views_df = None


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### N. LOADING THE VIEW METADATA DETAILS ###################################################
LoadTable = f"WH_MetaData.{ConfigSchemaName}.OneTimeConfigETL"
if selected_views_df is not None and selected_views_df.count() > 0:
    selected_views_df.write.mode("append").synapsesql(LoadTable)


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
