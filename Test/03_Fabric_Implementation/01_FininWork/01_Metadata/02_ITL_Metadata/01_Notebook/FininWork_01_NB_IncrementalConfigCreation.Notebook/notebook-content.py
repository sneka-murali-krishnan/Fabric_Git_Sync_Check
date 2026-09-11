# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse_name": "",
# META       "default_lakehouse_workspace_id": "",
# META       "known_lakehouses": [
# META         {
# META           "id": "9cdd052b-466d-41f0-905c-12e34f0ba66f"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

ConfigSchemaName = 'Config_FininWork'

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
col, lit, concat, when, trim, collect_list, row_number, to_date,date_format,
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
import requests
 
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

spark = SparkSession.builder \
    .appName("Oracle") \
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
    .config("spark.jars.packages", "com.crealytics:spark-excel_2.12:3.5.0_0.20.3") \
    .getOrCreate()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### SPARK SESSION ###################################################
spark = SparkSession.builder \
    .appName("Oracle") \
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
    OneTimeConfigETL=f"SELECT * FROM {ConfigSchemaName}.OneTimeConfigETL"
    OneTimeConfigETL_df= spark.read.option(Constants.DatabaseName, "WH_MetaData").synapsesql(OneTimeConfigETL)
except Exception as e:
    print(e) 

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

######################### DEFINING ABFSS PATH #######################
 
token = mssparkutils.credentials.getToken("https://api.fabric.microsoft.com")
headers = {"Authorization": f"Bearer {token}"}
workspace_id = mssparkutils.runtime.context.get("currentWorkspaceId")
if not workspace_id:
    raise Exception("No workspace context found. Attach notebook to a Lakehouse.")
print(f"Workspace ID: {workspace_id}")
url = f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/items"
items = requests.get(url, headers=headers).json().get("value", [])
lakehouses = [i for i in items if i["type"].lower() == "lakehouse"]
warehouses = [i for i in items if i["type"].lower() == "warehouse"]
bronze_lh = next(
    (lh for lh in lakehouses if lh["displayName"].upper().startswith("LH_BRONZE")),
    None,
)
silver_lh = next(
    (lh for lh in lakehouses if lh["displayName"].upper().startswith("LH_SILVER")),
    None,
)
if not bronze_lh:
    raise Exception("LH_BRONZE lakehouse not found in workspace")
if not silver_lh:
    raise Exception("LH_SILVER lakehouse not found in workspace")
print(f"Bronze Lakehouse ID: {bronze_lh['id']}")
print(f"Silver Lakehouse ID: {silver_lh['id']}")
warehouse = next(
    (wh for wh in warehouses if wh["displayName"].upper().startswith("WH_METADATA")),
    None,
)
if not warehouse:
    raise Exception("WH_METADATA warehouse not found in workspace")
print(f"Warehouse ID: {warehouse['id']}")
# Store IDs
bronze_lakehouse_id = bronze_lh["id"]
silver_lakehouse_id = silver_lh["id"]
warehouse_id = warehouse["id"]
 
# ABFSS paths using Lakehouse IDs
bronze_base_path = (
    f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/"
    f"{bronze_lakehouse_id}/Tables"
)
 
itl_metabronze_base_path = (
    f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/"
    f"{bronze_lakehouse_id}/Files/MetaData_ITL/FininWork.xlsx"
)

TableSelectionSheet = (
    f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/"
    f"{bronze_lakehouse_id}/Files/MetaData_ITL/TableSelection.xlsx"
)

silver_base_path = (
    f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/"
    f"{silver_lakehouse_id}/Tables"
)
# Warehouse references using Warehouse ID
WAREHOUSE_BATCH = f"{warehouse_id}.Log.ETLBatchHeader"
WAREHOUSE_SILVER = f"{warehouse_id}.Log.ETLBatchSilverDetails"
WAREHOUSE_CONFIG = f"{warehouse_id}.{ConfigSchemaName}.OneTimeConfigETL"

 

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Read sheet 2 (ITL_Config) for watermark fields
df_itl = pd.read_excel(itl_metabronze_base_path)

# Read sheet 1 (Table_Selection) for IsFullLoad chosen by user
df_sel = pd.read_excel(TableSelectionSheet)[['Id', 'IsFullLoad']]

# Merge IsFullLoad into itl df
df = df_itl.merge(df_sel, on='Id', how='left')

# Normalise: 'FullLoad' string -> 1, else 0
df['IsFullLoad'] = df['IsFullLoad'].apply(lambda x: 1 if str(x).strip().lower() == 'fullload' else 0)
print(df.columns.tolist())
display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# df = spark.read.format("com.crealytics.spark.excel") \
#     .option("header", "true") \
#     .option("inferSchema", "true") \
#     .load(path)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# watermark_df will be built from the uploaded Excel (df) in the next cell

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

watermark_df = spark.createDataFrame(df)
watermark_df = watermark_df.withColumnRenamed('Id', 'w_id')
# Keep IsFullLoad, CreatedWaterMarkField, UpdatedWaterMarkField; drop redundant cols
watermark_df = watermark_df.drop('SourceTableName', 'SourceSchemaName')

# CELL ********************

display(watermark_df)

# CELL ********************

validation = OneTimeConfigETL_df.join(
    watermark_df,
    (watermark_df.w_id == OneTimeConfigETL_df.Id),
    "left"
)
validation = validation.drop("w_id")

# CELL ********************

from pyspark.sql.functions import col, trim, when

Incremental_Config_df = validation.withColumn('CreatedWaterMarkField',
    when(
        (col('CreatedWaterMarkField').isNull()) | (trim(col('CreatedWaterMarkField')) == ''),
        None
    ).otherwise(trim(col('CreatedWaterMarkField')))
).withColumn('UpdatedWaterMarkField',
    when(
        (col('UpdatedWaterMarkField').isNull()) | (trim(col('UpdatedWaterMarkField')) == ''),
        None
    ).otherwise(trim(col('UpdatedWaterMarkField')))
)

# CELL ********************

from pyspark.sql.functions import col, when, lit, trim

# IncLoadType:
# 1 = FullLoad (no watermarks or user set FullLoad)
# 2 = CreatedOnly
# 3 = UpdatedOnly
# 4 = Created + Updated
Incremental_Config_df = Incremental_Config_df.withColumn('IncLoadType',
    when(
        (col('IsFullLoad') == 1) |
        (col('PrimaryKey').isNull()) | (trim(col('PrimaryKey')) == '') |
        (
            ((col('CreatedWaterMarkField').isNull()) | (trim(col('CreatedWaterMarkField')) == '')) &
            ((col('UpdatedWaterMarkField').isNull()) | (trim(col('UpdatedWaterMarkField')) == ''))
        ), lit(1)
    )
    .when(
        (col('CreatedWaterMarkField').isNotNull()) & (trim(col('CreatedWaterMarkField')) != '') &
        ((col('UpdatedWaterMarkField').isNull()) | (trim(col('UpdatedWaterMarkField')) == '')),
        lit(2)
    )
    .when(
        (col('UpdatedWaterMarkField').isNotNull()) & (trim(col('UpdatedWaterMarkField')) != '') &
        ((col('CreatedWaterMarkField').isNull()) | (trim(col('CreatedWaterMarkField')) == '')),
        lit(3)
    )
    .when(
        (col('CreatedWaterMarkField').isNotNull()) & (trim(col('CreatedWaterMarkField')) != '') &
        (col('UpdatedWaterMarkField').isNotNull()) & (trim(col('UpdatedWaterMarkField')) != ''),
        lit(4)
    )
    .otherwise(lit(1))
)

# Override IsFullLoad based on IncLoadType (in case user left it as IncrementalLoad but no watermarks)
Incremental_Config_df = Incremental_Config_df.withColumn(
    'IsFullLoad', when(col('IncLoadType') == 1, lit(1)).otherwise(lit(0))
)
Incremental_Config_df = Incremental_Config_df.withColumn(
    'IsSourceDelete', when(col('IsFullLoad') == 1, lit(0)).otherwise(lit(1))
)

# Split by load type for downstream processing
full_load_df                  = Incremental_Config_df.filter(col('IncLoadType') == 1)
CreatedBasedAudit_df          = Incremental_Config_df.filter(col('IncLoadType') == 2)
ModifiedBasedAudit_df         = Incremental_Config_df.filter(col('IncLoadType') == 3)
CreatedandModifedBasedAudit_df = Incremental_Config_df.filter(col('IncLoadType') == 4)

# CELL ********************

display(Incremental_Config_df.select(
    'Id', 'SourceSchemaName', 'SourceTableName',
    'CreatedWaterMarkField', 'UpdatedWaterMarkField',
    'IncLoadType', 'IsFullLoad', 'IsSourceDelete'
))

# CELL ********************

from pyspark.sql.functions import col, lit, to_timestamp
from pyspark.sql.types import TimestampType

# Dummy timestamp
dummy_ts = "1900-01-01 00:00:00"

# =============================================
# 1. Full Load (IncLoadType = 1) → Set dummy values
# =============================================
full_load_df = full_load_df.withColumn(
    "CreatedWaterMarkField", lit(1)
).withColumn(
    "CreatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
).withColumn(
    "UpdatedWaterMarkField", lit(1)
).withColumn(
    "UpdatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
)

# =============================================
# 2. Created Based (IncLoadType = 2)
# =============================================
CreatedBasedAudit_df = CreatedBasedAudit_df.withColumn(
    "CreatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
).withColumn(
    "UpdatedWaterMarkField", lit(1)
).withColumn(
    "UpdatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
)
# Note: CreatedWaterMarkField keeps its original config value

# =============================================
# 3. Modified Based (IncLoadType = 3)
# =============================================
ModifiedBasedAudit_df = ModifiedBasedAudit_df.withColumn(
    "CreatedWaterMarkField", lit(1)
).withColumn(
    "CreatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
).withColumn(
    "UpdatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
)
# Note: UpdatedWaterMarkField keeps its original value

# =============================================
# 4. Created + Modified Based (IncLoadType = 4)
# =============================================
CreatedandModifedBasedAudit_df = CreatedandModifedBasedAudit_df.withColumn(
    "CreatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
).withColumn(
    "UpdatedWaterMarkValue", to_timestamp(lit(dummy_ts), "yyyy-MM-dd HH:mm:ss")
)
# Both CreatedWaterMarkField & UpdatedWaterMarkField keep original values

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

Final_df = (
    full_load_df
    .union(ModifiedBasedAudit_df)
    .union(CreatedBasedAudit_df)
    .union(CreatedandModifedBasedAudit_df)
)

## Adding SourceDelete Query
primarykey_df = Final_df.filter(col("PrimaryKey").isNotNull())
NonPrimarykey_df = Final_df.filter(col("PrimaryKey").isNull())


################################################### SOURCE-TYPE-AWARE IDENTIFIER QUOTING ###################################################
# SQL Server / bracket quoting does not work against MySQL (or Oracle/Postgres, which use
# double quotes). Pick the correct quote characters once, based on ConfigSchemaName, the
# same way DBSource_ConfigCreation.ipynb does for SourceQuery.
def get_source_type(config_schema_name: str) -> str:
    name = (config_schema_name or "").lower()
    if "mysql" in name:
        return "mysql"
    elif "oracle" in name:
        return "oracle"
    elif "postgres" in name:
        return "postgres"
    elif "sqlserver" in name or "sql" in name:
        return "sqlserver"
    else:
        return "sqlserver"

_SOURCE_TYPE_QUOTE_CHARS = {
    "sqlserver": ("[", "]"),
    "oracle": ('"', '"'),
    "postgres": ('"', '"'),
    "mysql": ("`", "`"),
}
_source_type = get_source_type(ConfigSchemaName)
_quote_open, _quote_close = _SOURCE_TYPE_QUOTE_CHARS.get(_source_type, ("[", "]"))

primarykey_df=primarykey_df.withColumn("SourceDeleteQuery",
    when(
        col("IncLoadType") > 1,
    concat(
        lit('SELECT '),
        col('PrimaryKey'),
        lit(' FROM '),
        col('SourceSchemaName'),
        lit('.' + _quote_open),
        col('SourceTableName'),
        lit(_quote_close)
    )))
NonPrimarykey_df = NonPrimarykey_df.withColumn("SourceDeleteQuery",lit(''))

Final_df=primarykey_df.union(NonPrimarykey_df)



# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

selected_columns_df = Final_df.select(
    "Id",
    "SourceSchemaName",
    "SourceTableName",
    "BronzeSchemaName",
    "BronzeTableName",
    "SilverSchemaName",
    "SilverTableName",
    "LoadType",
    "PrimaryKey",
    "IsFullLoad",
    "IncLoadType",
    #"KeyAuditField1",
    #"KeyAuditField2",
    #"CreatedDateField",
    #"CreatedTimeField",
    #"ModifiedDateField",
    #"ModifiedTimeField",
    "SourceQuery",
    "IsSourceDelete",
    "SourceDeleteQuery",
    "CreatedWaterMarkField",
    "CreatedWaterMarkValue",
    "UpdatedWaterMarkField",
    "UpdatedWaterMarkValue",
    
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

current_utc_time = datetime.now(timezone.utc)
user_name = notebookutils.runtime.context.get("userName")

selected_columns_df = selected_columns_df.withColumn("LastModifiedDate",lit(current_utc_time)) \
                                        .withColumn("LastModifiedBy", lit(user_name)) \
                                        .withColumn("IsActive",lit(1))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(selected_columns_df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.types import *
from pyspark.sql import DataFrame

new_schema = StructType([
    StructField("Id", LongType(), True),
    StructField("SourceSchemaName", StringType(), True),
    StructField("SourceTableName", StringType(), True),
    StructField("BronzeSchemaName", StringType(), True),
    StructField("BronzeTableName", StringType(), True),
    StructField("SilverSchemaName", StringType(), True),
    StructField("SilverTableName", StringType(), True),
    StructField("LoadType", StringType(), True),
    StructField("PrimaryKey", StringType(), True),
    StructField("IsFullLoad", IntegerType(), True),
    StructField("IncLoadType", IntegerType(), True),
    StructField("SourceQuery", StringType(), True),
    StructField("IsSourceDelete", IntegerType(), True),
    StructField("SourceDeleteQuery", StringType(), True),
    StructField("CreatedWaterMarkField", StringType(), True),
    StructField("CreatedWaterMarkValue", TimestampType(), True),
    StructField("UpdatedWaterMarkField", StringType(), True),
    StructField("UpdatedWaterMarkValue", TimestampType(), True),
    StructField("LastModifiedDate", TimestampType(), True),
    StructField("LastModifiedBy", StringType(), True),
    StructField("IsActive", IntegerType(), True),

])

selected_columns_df = spark.createDataFrame(selected_columns_df.rdd, new_schema)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

selected_columns_df.write \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .synapsesql(f"WH_MetaData.{ConfigSchemaName}.IncrementalConfigETL")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
