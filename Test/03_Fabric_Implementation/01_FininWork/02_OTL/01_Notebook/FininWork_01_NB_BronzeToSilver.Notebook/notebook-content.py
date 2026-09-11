# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {}
# META }

# CELL ********************

############################################# IMPORTING REQUIRED PACKAGES ##############################################
from pyspark.sql import SparkSession
from pyspark.sql import DataFrame
from pyspark.sql.functions import (
col, lit, concat, when, trim, collect_list, row_number, to_date,date_format,
col, concat, lit, to_timestamp, date_format, to_date, coalesce,concat_ws, md5,
udf , concat, to_timestamp,count, when )
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
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, when
from pyspark.sql.functions import col, sum as _sum
import json
import requests
from pyspark.sql.types import *
from pyspark.sql import SparkSession, DataFrame
from delta.tables import DeltaTable
from pyspark.sql.functions import lit


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# PARAMETERS CELL ********************

################################################### NOTEBOOK PARAMETERS ####################################################
ETLBatchId = ''
AppMode = 'finin'

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### BUILDING CUSTOM SPARK SESSION ####################################################
spark = SparkSession.builder \
    .appName("SalesForceDataLoad") \
    .config("spark.sql.parquet.int96RebaseModeInRead", "CORRECTED") \
    .config("spark.sql.parquet.int96RebaseModeInWrite", "CORRECTED") \
    .config("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED") \
    .config("spark.sql.parquet.datetimeRebaseModeInRead", "CORRECTED") \
    .config("spark.gluten.enabled", "false") \
    .config("spark.sql.legacy.parquet.datetimeRebaseModeInWrite", "CORRECTED") \
    .config("spark.sql.legacy.parquet.datetimeRebaseModeInRead", "CORRECTED") \
    .config("spark.sql.caseSensitive", "true") \
    .config("spark.sql.extensions", "delta.sql.DeltaSparkSessionExtensions") \
    .config("spark.sql.catalog.spark_catalog", "delta.catalog.DeltaCatalog") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("spark.sql.legacy.timeParserPolicy", "LEGACY")\
    .getOrCreate()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### GETTING SPARK CONFIG DETAILS ####################################################
config_value = spark.conf.get("spark.executor.memoryOverhead", "Not Set")
config = spark.conf.get("spark.executor.memory", "Not Set")

print(f"spark.executor.memoryOverhead: {config_value}")
print(f"spark.executor.memory: {config}")
################################################### USER DEFINED VARIABLES ####################################################
current_utc_time = datetime.now(timezone.utc)
try:
    user_name = mssparkutils.env.getUserName()
except Exception as e:
    user_name = notebookutils.runtime.context.get("userName")
LogBasedFilter_Required = 1
bronze_log_filter = 1
ConfigSchemaName = 'Config_FininWork'

############################################################ DEFINING ABFSS PATH ##########################################################################
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

silver_base_path = (
    f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/"
    f"{silver_lakehouse_id}/Tables"
)
warehouse_config_path = (
    f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/"
    f"{warehouse_id}/Tables"
)

Log_details_path = f"{warehouse_config_path}/Log/ETLBatchBronzeDetails"


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### LOADING METADATA ####################################################
try:
    ConfigQuery = f"SELECT * FROM {ConfigSchemaName}.OneTimeConfigETL where IsActive = 1 "
    InformationSchemaTable = "SourceInformationSchemaMapped" if AppMode == "finin" else "SourceInformationSchema"
    InformationSchema=f"SELECT * FROM {ConfigSchemaName}.{InformationSchemaTable}"
    ConfigETL_df= spark.read.option(Constants.DatabaseName, "WH_MetaData").synapsesql(ConfigQuery) 
    InformationSchema_df= spark.read.option(Constants.DatabaseName, "WH_MetaData").synapsesql(InformationSchema) 
except Exception as e:
    print(e)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################# FILTERING THE BRONZE LAYER SUCCESS TABLES #################################
if bronze_log_filter == 1:
    BronzeSucess_df = spark.read.format('delta').load(Log_details_path)
    BronzeSucess_df.createOrReplaceTempView("ETLBatchBronzeDetails")
    display(BronzeSucess_df)
    display(ETLBatchId)
    BronzeSucessQuery = f"SELECT * FROM ETLBatchBronzeDetails WHERE BatchId = '{ETLBatchId}' AND Status ='Success' and ExtractedRowCount <> 0"
    BronzeSucess_df = spark.sql(BronzeSucessQuery)
    display(BronzeSucess_df)
    bronze_success_df_id = BronzeSucess_df.select(col("TableId"))
    display(bronze_success_df_id)
    bronze_success_table_id = [
        row["TableId"] 
        for row in bronze_success_df_id
            .filter(bronze_success_df_id["TableId"].cast("int").isNotNull())
            .withColumn("TableId", bronze_success_df_id["TableId"].cast("string"))
            .collect()
    ]
    ConfigETL_df = ConfigETL_df.filter(col("Id").isin(bronze_success_table_id))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(BronzeSucess_df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(ConfigETL_df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### USER DEFINED FUNCTION: 1.EXTRACTING BRONZE DATA ####################################################
def Read_bronze_data(BronzeSchemaName, BronzeTableName):
    is_okay = 1
    error_message = None
    msg = ''
    read_type = 'Table'
    base_path = bronze_base_path
    if read_type == 'Table':
        try:
            bronze_abfss_path = f"{base_path}/{BronzeSchemaName}/{BronzeTableName}"
            bronze_df = spark.read.format('delta').load(bronze_abfss_path)    
            bronze_df = bronze_df.drop_duplicates()
            msg = f"Data has been successfully extracted for Schema Name {BronzeSchemaName}, Table Name: {BronzeTableName}"
        except Exception as e:
            msg = f"An error occurred while extracting data for Schema Name: {BronzeSchemaName}, Table Name: {BronzeTableName}"
            error_message = str(e)
            print(error_message)
            bronze_df = None
            is_okay  = 0
            return is_okay, bronze_df, msg, error_message
    else:
        if read_type == 'File':
            print(read_type)
            try:
                bronze_abfss_path = f"{base_path}/Files/{BronzeSchemaName}/{BronzeTableName}/*.parquet"
                print(bronze_abfss_path)
                bronze_df = spark.read \
                .option("spark.sql.parquet.inferTimestampNTZ.enabled","false") \
                .parquet(bronze_abfss_path)
                # bronze_df = spark.read.format('parquet').load(bronze_abfss_path)
                print("Data REad")    
                bronze_df = bronze_df.drop_duplicates()
                msg = f"Data has been successfully extracted for Schema Name {BronzeSchemaName}, Table Name: {BronzeTableName}"
            except Exception as e:
                msg = f"An error occurred while extracting data for Schema Name: {BronzeSchemaName}, Table Name: {BronzeTableName}"
                error_message = str(e)
                bronze_df = None
                print(error_message)
                is_okay  = 0
                return is_okay, bronze_df, msg, error_message
    return is_okay, bronze_df, msg, error_message

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### USER DEFINED FUNCTION: 2.DATA TYPE CASTING & TABLE SPLIT ####################################################
def data_type_casting_split(table_name, bronze_df, config_mapping_schema_df, primary_key, default_target_table):
    """Casts + splits a single bronze table into one-or-more Silver tables.

    SourceInformationSchemaMapped (Finin) maps SourceColumnName -> TargetTableName /
    TargetColumnName / TargetDataType at the column level, so one bronze table can
    fan out into several silver tables. Only the columns that actually appear in
    the mapping are re-typed/renamed and routed to their mapped TargetTableName.

    Every OTHER bronze column — anything with no row at all in
    SourceInformationSchemaMapped for this table — is NOT dropped. It's carried
    through unchanged (original name, original type) into a fallback/default
    split named *default_target_table* (the source table's own SilverTableName
    from OneTimeConfigETL, i.e. the same single-table target used when there's
    no mapping at all). If the mapping happens to explicitly route some columns
    to that same table name too, they're merged into the one dataframe rather
    than being produced twice.

    The base table's primary key is force-included (by source name, or its
    mapped target name where one exists) in every split — mapped or fallback —
    so each split can be incrementally merged/upserted on its own.
    """
    is_okay = 1
    error_message = None
    msg = 'Data Type Casting & Split was Successful'
    split_frames = {}
    split_primary_keys = {}

    data_type_mapping = {
        'double': DoubleType(),
        'email': StringType(),
        'long': LongType(),
        'location': StringType(),
        'address': StringType(),
        'encryptedstring': StringType(),
        'id': StringType(),
        'picklist': StringType(),
        'base64': BinaryType(),
        'int': IntegerType(),
        'complexvalue': StringType(),
        'currency': DoubleType(),
        'string': StringType(),
        'combobox': StringType(),
        'percent': DoubleType(),
        'textarea': StringType(),
        'phone': StringType(),
        'anyType': StringType(),
        'reference': StringType(),
        'datetime': TimestampType(),
        'date': DateType(),
        'boolean': BooleanType(),
        'multipicklist': StringType(),
        'url': StringType(),
        'VARCHAR2': StringType(),
        'TIMESTAMP(6) WITH TIME ZONE': TimestampType(),
        'DATE': TimestampType(),
        'NVARCHAR2': StringType(),
        'NUMBER': DoubleType(),
        'CHAR': StringType(),
        'RAW': StringType(),
        'CLOB': StringType(),
        'XMLTYPE': StringType(),
        'varchar': StringType(),
        'nvarchar': StringType(),
        'char': StringType(),
        'text': StringType(),
        'bit': BooleanType(),
        'decimal': DoubleType(),
        'numeric': DoubleType(),
        'float': DoubleType(),
        'bigint': LongType(),
        'smallint': IntegerType(),
        'tinyint': IntegerType(),
        'uniqueidentifier': StringType(),
        'datetime2': TimestampType(),
    }

    try:
        for col_name in config_mapping_schema_df.columns:
            config_mapping_schema_df = config_mapping_schema_df.withColumnRenamed(
                col_name,
                col_name.upper()
            )

        table_config = config_mapping_schema_df.filter(col("SOURCETABLENAME") == table_name)

        ####################################### PARSE THE BASE TABLE'S PRIMARY KEY ###################################
        if primary_key:
            if isinstance(primary_key, str):
                base_pk_list = [c.strip() for c in primary_key.split(",")]
            elif isinstance(primary_key, list) and len(primary_key) == 1 and isinstance(primary_key[0], str) and "," in primary_key[0]:
                base_pk_list = [c.strip() for c in primary_key[0].split(",")]
            elif isinstance(primary_key, list):
                base_pk_list = primary_key
            else:
                base_pk_list = primary_key.tolist()
        else:
            base_pk_list = []

        # target_select_cols: {target_table: {output_col_name: Column expr}}
        # target_source_cols: {target_table: set(source_col_names already consumed)} — used to
        #   avoid re-adding a column and to know what still needs a PK backfill.
        # target_pk_cols:     {target_table: [output pk col names]}
        target_select_cols = {}
        target_source_cols = {}
        target_pk_cols = {}
        mapped_source_cols_global = set()

        ####################################### 1. ROUTE EXPLICITLY MAPPED COLUMNS ###################################
        for row in table_config.collect():
            source_col = row['SOURCECOLUMNNAME']
            target_col = row['TARGETCOLUMNNAME']
            target_table = row['TARGETTABLENAME']
            target_type = row['TARGETDATATYPE']

            if not target_table:
                print(f"Mapping row for '{table_name}.{source_col}' has no TargetTableName. Skipping this mapping (column still protected by the no-data-loss fallback below).")
                continue
            if source_col not in bronze_df.columns:
                print(f"Column '{source_col}' does not exist in bronze data for '{table_name}'. Skipping...")
                continue

            spark_data_type = data_type_mapping.get(
                target_type, data_type_mapping.get(str(target_type).lower(), StringType())
            )
            target_select_cols.setdefault(target_table, {})[target_col] = col(source_col).cast(spark_data_type).alias(target_col)
            target_source_cols.setdefault(target_table, set()).add(source_col)
            mapped_source_cols_global.add(source_col)

            if source_col in base_pk_list:
                target_pk_cols.setdefault(target_table, []).append(target_col)

        ####################################### 2. NO-DATA-LOSS FALLBACK FOR UNMAPPED COLUMNS #########################
        # Any bronze column with no mapping row at all (for ANY target table) still needs a home —
        # carry it through as-is into the default/fallback target instead of dropping it.
        unmapped_cols = [c for c in bronze_df.columns if c not in mapped_source_cols_global]
        if unmapped_cols:
            for source_col in unmapped_cols:
                target_select_cols.setdefault(default_target_table, {})[source_col] = col(source_col)
                target_source_cols.setdefault(default_target_table, set()).add(source_col)
                if source_col in base_pk_list:
                    target_pk_cols.setdefault(default_target_table, []).append(source_col)

        ####################################### 3. ENSURE PRIMARY KEY IS PRESENT IN EVERY SPLIT ########################
        for target_table in list(target_select_cols.keys()):
            already_have = target_source_cols.get(target_table, set())
            for pk_col in base_pk_list:
                if pk_col in already_have or pk_col not in bronze_df.columns:
                    continue
                target_select_cols[target_table][pk_col] = col(pk_col)
                target_source_cols[target_table].add(pk_col)
                target_pk_cols.setdefault(target_table, []).append(pk_col)

        ####################################### 4. BUILD FINAL DATAFRAMES ###################################
        for target_table, cols_dict in target_select_cols.items():
            if not cols_dict:
                continue
            split_frames[target_table] = bronze_df.select(*cols_dict.values())
            # De-dupe while preserving order (a PK column can be added via both
            # explicit mapping and the ensure-PK backfill step).
            split_primary_keys[target_table] = list(dict.fromkeys(target_pk_cols.get(target_table, [])))

        if not split_frames:
            is_okay = 0
            msg = f"Data Type Casting & Split produced no output tables for {table_name}"
        elif unmapped_cols and default_target_table in split_frames:
            msg = (f"Data Type Casting & Split was Successful "
                   f"({len(unmapped_cols)} unmapped column(s) carried through as-is into '{default_target_table}')")

    except TypeError as e:
        is_okay = 0
        error_message = str(e)
        msg = 'Data Type Casting & Split Failed due to Type Error'
    except ValueError as e:
        is_okay = 0
        error_message = str(e)
        msg = 'Data Type Casting & Split Failed due to Value Error'
    except Exception as e:
        is_okay = 0
        error_message = str(e)
        msg = 'Data Type Casting & Split Failed due to General Error'

    return is_okay, split_frames, split_primary_keys, msg, error_message

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### USER DEFINED FUNCTION: 3.ADDING WAREHOUSE AUDIT COLUMNS ####################################################
def adding_ETLWarehousing_Columns(bronze_df:DataFrame):
        is_okay = 1
        error_message = None
        msg = 'Adding ETL Warehousing Audit columns'
        current_utc_time = datetime.now(pytz.UTC)
        try:
            user_name = mssparkutils.env.getUserName()
        except Exception as e:
            user_name = notebookutils.runtime.context.get("userName")
        try:
            bronze_df = bronze_df.withColumn(
                                        "HashKey",
                                        md5(concat_ws("", *[col(c).cast("string") for c in bronze_df.columns]))
                                    )
            bronze_df = bronze_df.withColumn("ETLLoadedDate", lit(current_utc_time)) \
                                .withColumn("ETLLoadedBy", lit(user_name)) \
                                .withColumn("ETLModifiedDate", lit(current_utc_time)) \
                                .withColumn("ETLModifiedBy", lit(user_name)) 
            return is_okay, bronze_df, msg, error_message 
        except Exception as e:
            is_okay = 0
            error_message = str(e)
            msg= "Failed During adding warehouse Audit Columns"
            return is_okay, bronze_df, msg, error_message  

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### USER DEFINED FUNCTION: 4. SOURCE DELETE ####################################################
from pyspark.sql.functions import col, lit
from delta.tables import DeltaTable
import traceback

def Source_delete(spark, bronze_df, silver_schema_name, silver_table_name, primary_key):
    is_okay = 1
    error_message = None
    msg = ''
    source_delete_count = None
    pk_list = []

    silver_generic_path = silver_base_path
    silver_relative_path = f"{silver_schema_name}/{silver_table_name}"
    silver_absolute_path = f"{silver_generic_path}/{silver_relative_path}"

    try:
        ####################################### 1. PARSE PRIMARY KEY ###################################
        if primary_key:
            if isinstance(primary_key, str):
                pk_list = [c.strip() for c in primary_key.split(",")]
            elif isinstance(primary_key, list) and len(primary_key) == 1 and isinstance(primary_key[0], str) and "," in primary_key[0]:
                pk_list = [c.strip() for c in primary_key[0].split(",")]
            elif isinstance(primary_key, list):
                pk_list = primary_key
            else:
                pk_list = primary_key.tolist()
        else:
            raise ValueError("Primary key is required for source delete capture.")

        ####################################### 2. SOURCE DATA = ALREADY-READ BRONZE DATA #############
        source_df = bronze_df

        ####################################### 3. CHECK IF SILVER TABLE EXISTS ###################################
        if not DeltaTable.isDeltaTable(spark, silver_absolute_path):
            msg = f"Delta table does not exist at {silver_absolute_path}. No Source Delete will be captured"
            return is_okay, msg, error_message, source_delete_count

        ####################################### 4. LOAD SILVER DELTA TABLE ###################################
        silver_delta_table = DeltaTable.forPath(spark, silver_absolute_path)
        silver_df = silver_delta_table.toDF()
        if silver_df.count() < 1:
            msg = f"Delta table does have some problem {silver_absolute_path}. No Source Delete will be captured"
            return is_okay, msg, error_message, source_delete_count

        ####################################### 5. IDENTIFY MISSING RECORDS (SOURCE DELETES) ###########
        join_condition = [silver_df[k] == source_df[k] for k in pk_list]
        missing_df = silver_df.join(source_df, join_condition, how="left_anti")
        source_delete_count = missing_df.count()

        ####################################### 6. MARK MISSING RECORDS AS SOURCE DELETED ##############
        if source_delete_count > 0:
            merge_condition = " AND ".join([f"t.{k} = s.{k}" for k in pk_list])
            delete_keys_df = missing_df.select(*pk_list)

            silver_delta_table.alias("t") \
                .merge(delete_keys_df.alias("s"), merge_condition) \
                .whenMatchedDelete() \
                .execute()

            msg = f"Source Hard Delete Completed: {source_delete_count} rows deleted from silver table."
        else:
            msg = "No records found for Source Delete."

    except Exception as e:
        is_okay = 0
        msg = "Error during source hard delete process"
        error_message = str(e)
        traceback.print_exc()

    return is_okay, msg, error_message, source_delete_count

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

############################################# 7. USER DEFINED FUNCTION TO PERFORM FULL LOAD   ########################################################################
def data_load(spark: SparkSession, bronze_df: DataFrame, SilverTableName: str, SilverSchemaName: str, PrimaryKey):
    is_okay = 1
    silver_data_msg = ''
    error_message = None
    generic_path = silver_base_path
    relative_path = f"{SilverSchemaName}/{SilverTableName}"
    absolute_path = f"{generic_path}/{relative_path}"

    overwrite = 0
    pk_list = []
    dataframe = bronze_df
    update_count = 0
    source_delete_count = 0
        ####################################### 1. PARSE PRIMARY KEY ###################################
    try:
        if PrimaryKey:
            if isinstance(PrimaryKey, str):
                pk_list = [col.strip() for col in PrimaryKey.split(",")]
            elif isinstance(PrimaryKey, list) and len(PrimaryKey) == 1 and isinstance(PrimaryKey[0], str) and "," in PrimaryKey[0]:
                pk_list = [col.strip() for col in PrimaryKey[0].split(",")]
            elif isinstance(PrimaryKey, list):
                pk_list = PrimaryKey
            else:
                pk_list = PrimaryKey.tolist()
        else:
            overwrite = 1
    except Exception as e:
        is_okay = 0
        silver_data_msg = 'Error While Extracting PrimaryKey'
        error_message = str(e)
        return is_okay, silver_data_msg, error_message
 

    try:       
        ####################################### 2. INITIAL WRITE IF TABLE DOES NOT EXIST ###################################
        if not DeltaTable.isDeltaTable(spark, absolute_path):
            try:
                dataframe.write.mode("overwrite") \
                    .format("delta") \
                    .option("overwriteSchema", "true") \
                    .save(absolute_path)
                
                silver_data_msg = f'Initial Load Completed for {SilverSchemaName}.{SilverTableName}'
                return is_okay, silver_data_msg, error_message
            except Exception as e:
                is_okay = 0
                silver_data_msg = 'Error While Performing Initial Load'
                error_message = str(e)
                return is_okay, silver_data_msg, error_message

        ####################################### 3. FULL OVERWRITE CASE IF NO PRIMARY KEY ###################################
        elif overwrite == 1:
            try:
                dataframe.write.mode("overwrite") \
                    .format("delta") \
                    .option("overwriteSchema", "true") \
                    .save(absolute_path)

                silver_data_msg = f'Full Load Completed for {SilverSchemaName}.{SilverTableName} (No PK)'
                return is_okay, silver_data_msg, error_message
            except Exception as e:
                is_okay = 0
                silver_data_msg = 'Error While Performing Full Load'
                error_message = str(e)
                return is_okay, silver_data_msg, error_message

        ####################################### 4. MERGE AND SOURCE DELETE CASE ###################################
        else:
            try:
                ####################################### 4.1 LOAD TARGET DATA ###################################
                try:
                    
                    delta_table = DeltaTable.forPath(spark, absolute_path)
                    target_df = delta_table.toDF().select("HashKey", *pk_list)
                    source_df = dataframe.select("HashKey", *pk_list)
                except Exception as e:
                    is_okay = 0
                    silver_data_msg = 'Error While Loading the target tables'
                    error_message = str(e)
                    return is_okay, silver_data_msg, error_message
                ####################################### 4.2 IDENTIFY NEW/UPDATED RECORDS ###################################
                try:
                    filtered_source_df = dataframe.join(
                        target_df,
                        on=["HashKey"] + pk_list,
                        how="left_anti"
                    )
                    new_count = filtered_source_df.count()
                except Exception as e:
                    is_okay = 0
                    silver_data_msg = 'Error While Getting new/updated records'
                    error_message = str(e)
                    return is_okay, silver_data_msg, error_message
                
                ####################################### 4.3 IDENTIFY UPDATED RECORDS (PK MATCH BUT HASHKEY DIFFERENT) ###################################
                try:
                    # PK matches but HashKey different => Update
                    updated_records_df = dataframe.alias("src").join(
                        target_df.alias("tgt"),
                        on=pk_list,
                        how="inner"
                    ).filter("src.HashKey != tgt.HashKey").select("src.*")
                    update_count = updated_records_df.count()
                except Exception as e:
                    is_okay = 0
                    silver_data_msg = 'Error While Identifying Updated Records'
                    error_message = str(e)
                    return is_okay, silver_data_msg, error_message
                
                ####################################### 4.3 DELETE OLD VERSIONS ###################################

                try:
                    merge_condition = " AND ".join([f"t.{k} = s.{k}" for k in pk_list])
                    merge_condition = f"({merge_condition}) AND t.HashKey != s.HashKey"
                    delta_table.alias("t") \
                        .merge(
                            source_df.alias("s"),
                            merge_condition
                        ) \
                        .whenMatchedDelete() \
                        .execute()
                except Exception as e:
                    is_okay = 0
                    silver_data_msg = 'Error While Deleting old versions'
                    error_message = str(e)
                    return is_okay, silver_data_msg, error_message
                
                ####################################### 4.4 LOAD NEW/UPDATED RECORDS ###################################
                try:
                    combined_df = filtered_source_df.unionByName(updated_records_df)
                    combined_df.write.mode("append") \
                        .format("delta") \
                        .option("mergeSchema", "true") \
                        .save(absolute_path)
                    silver_data_msg = (f'Incremental Load Completed for {SilverSchemaName}.{SilverTableName} | '
                                       f'New Inserts: {new_count}, Updates: {update_count}')
                except Exception as e:
                    is_okay = 0
                    silver_data_msg = 'Error While Appending Records'
                    error_message = str(e)
                    return is_okay, silver_data_msg, error_message
            except Exception as e:
                is_okay = 0
                silver_data_msg = 'Error in merge operation'
                error_message = str(e)
                return is_okay, silver_data_msg, error_message
    except Exception as e:
        is_okay = 0
        silver_data_msg = 'Unexpected error in full load'
        error_message = str(e)
    return is_okay, silver_data_msg, error_message

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### USER DEFINED FUNCTION: 5.LOADING BRONZE DETAIL LOG  ####################################################
def update_table_level_log(log_dict,  EndTime=None, DurationInSec=None,
                            BronzeDataRead=None, DataTypeCasting=None, 
                            BronzeCount=None, SilverCount=None,
                            SourceDelete=None,
                            SilverDataLoad=None,
                            ErrorMessage=None, Status=None):
    

    if EndTime is not None:
        log_dict["EndTime"] = EndTime
    if DurationInSec is not None:
        log_dict["DurationInSec"] = DurationInSec
    if BronzeDataRead is not None:
        log_dict["BronzeDataRead"] = BronzeDataRead
    if DataTypeCasting is not None:
        log_dict["DataTypeCasting"] = DataTypeCasting
    if BronzeCount is not None:
        log_dict["BronzeCount"] = BronzeCount
    if SilverCount is not None:
        log_dict["SilverCount"] = SilverCount
    if SourceDelete is not None:
        log_dict["SourceDelete"] = SourceDelete
    if SilverDataLoad is not None:
        log_dict["SilverDataLoad"] = SilverDataLoad
    if ErrorMessage is not None:
        log_dict["ErrorMessage"] = ErrorMessage
    if Status is not None:
        log_dict["Status"] = Status
    return log_dict

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

############################################  MAIN BLOCK ##################################################
def process_table(row, InformationSchema_df, ETLBatchId):
    ################################### DECLARING THE REQUIRED VARIABLES #####################################
    start_utc_time = datetime.now(timezone.utc)
    try:
        user_name = mssparkutils.env.getUserName()
    except Exception as e:
        user_name = notebookutils.runtime.context.get("userName")
    failure_message = 'Not executed due to prior Failure'
    skip_message = "No new records were found; skip further processing"
    #################################### ACCESSING THE METADATA OF THE TABLE #################################
    TableId = row['Id']
    SourceTableName = row['SourceTableName']
    SourceSchemaName = row['SourceSchemaName']
    BronzeSchemaName = row['BronzeSchemaName']
    BronzeTableName = row['BronzeTableName']
    SilverSchemaName = row["SilverSchemaName"]
    SilverTableName = row["SilverTableName"]
    PrimaryKey = row['PrimaryKey']

    ####################################### DICTIONARY FOR TABLE LEVEL LOG DETAILS ####################################
    # Base template for a log row; one row is emitted per split (target) table,
    # since Finin's mapped schema can fan a single bronze table out into several
    # Silver tables. TargetTableName is appended (not inserted) to keep the
    # existing column positions/consumers of ETLBatchSilverLogDetails intact.
    def base_log():
        return {
            "LogHeaderId": ETLBatchId,
            "TableId": TableId,
            "TableName": SourceTableName,
            "SchemaName": SourceSchemaName,
            "StartTime": start_utc_time,
            "EndTime": '',
            "DurationInSec": '',
            "BronzeDataRead": '',
            "DataTypeCasting": '',
            "BronzeCount": None,
            "SilverCount": None,
            "SilverDataLoad": '',
            "SourceDelete": '',
            "ErrorMessage": '',
            "Status": '',
            "ETLLoadedBy": user_name,
            "TargetTableName": ''
        }

    print(f"Started Bronze To Silver Process for SchemaName: {BronzeSchemaName} - TableName: {SourceTableName}")

    ####################################### 1. BRONZE DATA READ ##############################################
    is_okay, bronze_df, msg, error_message = Read_bronze_data(BronzeSchemaName, BronzeTableName)
    if bronze_df is None or is_okay == 0:
        log = update_table_level_log(
            base_log(),
            EndTime=datetime.now(timezone.utc),
            DurationInSec=(datetime.now(timezone.utc) - start_utc_time).total_seconds(),
            BronzeDataRead=msg,
            DataTypeCasting=failure_message,
            SilverDataLoad=failure_message,
            ErrorMessage=error_message,
            Status="Failure"
        )
        print(f"Error Occured while extracting the data from the bronze layer for SchemaName: {BronzeSchemaName} - TableName: {SourceTableName}")
        return [log]

    bronze_count = bronze_df.count()
    if bronze_count == 0:
        log = update_table_level_log(
            base_log(),
            EndTime=datetime.now(timezone.utc),
            DurationInSec=(datetime.now(timezone.utc) - start_utc_time).total_seconds(),
            BronzeDataRead=msg,
            DataTypeCasting=skip_message,
            BronzeCount=0,
            SilverCount=0,
            SilverDataLoad=skip_message,
            ErrorMessage=None,
            Status="Success"
        )
        print(f"No New Record was extracting the data from the bronze layer for SchemaName: {BronzeSchemaName} - TableName: {SourceTableName}")
        return [log]

    bronze_read_msg = msg

    ####################################### 2. DATA TYPE CASTING & SPLIT ##############################################
    for col_name in InformationSchema_df.columns:
        InformationSchema_df = InformationSchema_df.withColumnRenamed(
            col_name,
            col_name.upper()
        )
    data_typecasting_df = InformationSchema_df.filter((col("SOURCETABLENAME") == SourceTableName))
    is_okay, split_frames, split_primary_keys, msg, error_message = data_type_casting_split(
        SourceTableName, bronze_df, data_typecasting_df, PrimaryKey, SilverTableName
    )
    if is_okay == 0:
        log = update_table_level_log(
            base_log(),
            EndTime=datetime.now(timezone.utc),
            DurationInSec=(datetime.now(timezone.utc) - start_utc_time).total_seconds(),
            BronzeDataRead=bronze_read_msg,
            BronzeCount=bronze_count,
            DataTypeCasting=msg,
            SilverDataLoad=failure_message,
            ErrorMessage=error_message,
            Status="Failure"
        )
        print(f"Error Occured during data type casting/split for SchemaName: {BronzeSchemaName} - TableName: {SourceTableName}")
        return [log]

    ####################################### 3. PER-SPLIT-TABLE: AUDIT COLS + SOURCE DELETE + INCREMENTAL LOAD #########
    table_logs = []
    for target_table_name, split_df in split_frames.items():
        target_pk_list = split_primary_keys.get(target_table_name, [])

        log = base_log()
        log["TargetTableName"] = target_table_name
        log = update_table_level_log(log, BronzeDataRead=bronze_read_msg, BronzeCount=bronze_count, DataTypeCasting=msg)

        ################################### 3.1 ETL WAREHOUSE AUDIT COLUMNS ##############################
        is_okay, split_df, awc_msg, error_message = adding_ETLWarehousing_Columns(split_df)
        if is_okay == 0:
            log = update_table_level_log(
                log,
                EndTime=datetime.now(timezone.utc),
                DurationInSec=(datetime.now(timezone.utc) - start_utc_time).total_seconds(),
                SilverDataLoad=failure_message,
                ErrorMessage=error_message,
                Status="Failure"
            )
            print(f"The Adding Warehouse Audit Columns was failed for SchemaName: {SilverSchemaName} - TargetTable: {target_table_name}")
            table_logs.append(log)
            continue

        ################################### 3.2 SOURCE DELETE (INCREMENTAL) ##############################
        is_okay, source_delete_msg, error_message, source_delete_count = Source_delete(
            spark, split_df, SilverSchemaName, target_table_name, target_pk_list
        )
        if is_okay == 0:
            log = update_table_level_log(
                log,
                EndTime=datetime.now(timezone.utc),
                DurationInSec=(datetime.now(timezone.utc) - start_utc_time).total_seconds(),
                SourceDelete=source_delete_msg,
                SilverDataLoad=failure_message,
                ErrorMessage=error_message,
                Status="Failure"
            )
            print(f"Error Occurred during source delete for SchemaName: {SilverSchemaName} - TargetTable: {target_table_name}")
            table_logs.append(log)
            continue
        else:
            log = update_table_level_log(log, SourceDelete=source_delete_msg)

        ################################### 3.3 SILVER LAYER DATA LOAD (INCREMENTAL MERGE) ##############################
        is_okay, silver_data_msg, error_message = data_load(
            spark, split_df, target_table_name, SilverSchemaName, target_pk_list
        )
        if is_okay == 0:
            log = update_table_level_log(
                log,
                EndTime=datetime.now(timezone.utc),
                DurationInSec=(datetime.now(timezone.utc) - start_utc_time).total_seconds(),
                SilverDataLoad=silver_data_msg,
                SourceDelete=source_delete_msg,
                ErrorMessage=error_message,
                Status="Failure"
            )
            print(f"Data Load was Failed for SchemaName: {SilverSchemaName} - TargetTable: {target_table_name}")
        else:
            log = update_table_level_log(
                log,
                EndTime=datetime.now(timezone.utc),
                DurationInSec=(datetime.now(timezone.utc) - start_utc_time).total_seconds(),
                SilverDataLoad=silver_data_msg,
                SourceDelete=source_delete_msg,
                SilverCount=split_df.count(),
                ErrorMessage=None,
                Status="Success"
            )
            print(f"Data Load was Completed for SchemaName: {SilverSchemaName} - TargetTable: {target_table_name}")

        table_logs.append(log)

    ####################################### THE END #############################################################
    return table_logs

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(ConfigETL_df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### EXECUTION BLOCK ####################################################
log_list = []
max_executors = 20
def process_row(row):
    return process_table(row, InformationSchema_df, ETLBatchId)
try:
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_executors) as executor:
        futures = {executor.submit(process_row, row): row for row in ConfigETL_df.toLocalIterator()}
        for future in concurrent.futures.as_completed(futures):
            # process_table now returns a LIST of log rows (one per split/target
            # table produced from SourceInformationSchemaMapped), so extend
            # rather than append.
            log_entries = future.result()
            log_list.extend(log_entries)
    if not log_list:
        print("No logs generated. Check the processing function.")
        log_df = pd.DataFrame()
    else:
        log_df = pd.DataFrame(log_list)
        log_df = log_df.astype(str)

except Exception as e:
    print(f"An error occurred: {e}")
    print(str(e))
    log_df = pd.DataFrame(log_list)
    log_df = log_df.astype(str)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

################################################### SAVING LOG DETAILS ####################################################
schema = StructType([
    StructField("LogHeaderId", StringType(), True),
    StructField("TableId", StringType(), True),
    StructField("SchemaName", StringType(), True),
    StructField("TableName", StringType(), True),
    StructField("StartTime", StringType(), True),
    StructField("EndTime", StringType(), True),
    StructField("DurationInSec", StringType(), True),
    StructField("BronzeDataRead", StringType(), True),
    StructField("DataTypeCasting", StringType(), True),
    StructField("BronzeCount", StringType(), True),
    StructField("SilverCount", StringType(), True),
    StructField("SourceDelete", StringType(), True),
    StructField("SilverDataLoad", StringType(), True),
    StructField("ErrorMessage", StringType(), True),
    StructField("Status", StringType(), True),
    StructField("EtlLoadedBy", StringType(), True),
    StructField("TargetTableName", StringType(), True)
])
spark.conf.set("spark.sql.execution.arrow.pyspark.enabled", "true")
################################################### SAVING LOG DETAILS ####################################################
spark_df = spark.createDataFrame(log_df, schema=schema)
spark_df = spark_df.withColumn("BronzeCount", col("BronzeCount").cast(LongType()).cast(StringType()))
spark_df = spark_df.withColumn("SilverCount", col("SilverCount").cast(LongType()).cast(StringType()))
spark_df = spark_df.withColumnRenamed("LogHeaderId","BatchId")
spark_df.write.option("overwriteSchema","true").mode("append").synapsesql("WH_MetaData.Log.ETLBatchSilverLogDetails")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(spark_df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
