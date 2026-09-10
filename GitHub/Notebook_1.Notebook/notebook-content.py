# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {}
# META }

# CELL ********************

%pip install semantic-link-labs --upgrade --quiet

import sempy_labs.directlake as dl

workspace_name_or_id = "74da0728-60bf-45a7-8063-e47582cdb26e"
warehouse_name = "WH_Gold"
semantic_model_name = "SM_Gold"

# Tables from WH_Gold to include
gold_tables = [
    "gold.DimDate",
    "gold.DimCustomer",
    "gold.DimProduct",
    "gold.DimStore",
    "gold.DimEmployee",
    "gold.FactSales",
    "gold.FactPayments",
    "gold.FactReturns",
    "gold.FactInventory",
    "gold.AggMonthlySales"
]

print(f"Generating Direct Lake Semantic Model '{semantic_model_name}' on top of '{warehouse_name}'...")

dl.generate_direct_lake_semantic_model(
    dataset=semantic_model_name,
    workspace=workspace_name_or_id,
    source=warehouse_name,
    source_type="Warehouse",
    tables=gold_tables,
    overwrite=True
)

print(f"Done! '{semantic_model_name}' is successfully created.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from sempy_labs.tom import connect_semantic_model

workspace = "74da0728-60bf-45a7-8063-e47582cdb26e"  # Or your workspace name
dataset = "SM_Gold"

# Define the star-schema relationships
relationships = [
    # FactSales -> Dimensions
    {"from_table": "FactSales", "from_column": "DateKey",     "to_table": "DimDate",     "to_column": "DateKey"},
    {"from_table": "FactSales", "from_column": "CustomerID",  "to_table": "DimCustomer", "to_column": "CustomerID"},
    {"from_table": "FactSales", "from_column": "ProductID",   "to_table": "DimProduct",  "to_column": "ProductID"},
    {"from_table": "FactSales", "from_column": "StoreID",     "to_table": "DimStore",    "to_column": "StoreID"},
    {"from_table": "FactSales", "from_column": "EmployeeID",  "to_table": "DimEmployee", "to_column": "EmployeeID"},

    # FactPayments -> Dimensions
    {"from_table": "FactPayments", "from_column": "DateKey",  "to_table": "DimDate",     "to_column": "DateKey"},

    # FactReturns -> Dimensions
    {"from_table": "FactReturns", "from_column": "DateKey",   "to_table": "DimDate",     "to_column": "DateKey"},

    # FactInventory -> Dimensions
    {"from_table": "FactInventory", "from_column": "DateKey",   "to_table": "DimDate",   "to_column": "DateKey"},
    {"from_table": "FactInventory", "from_column": "ProductID", "to_table": "DimProduct", "to_column": "ProductID"},
]

# Connect to the model in read-write mode and add relationships
with connect_semantic_model(dataset=dataset, workspace=workspace, readonly=False) as tom:
    for rel in relationships:
        print(f"Adding relationship: {rel['from_table']}[{rel['from_column']}] -> {rel['to_table']}[{rel['to_column']}]")
        tom.add_relationship(
            from_table=rel["from_table"],
            from_column=rel["from_column"],
            to_table=rel["to_table"],
            to_column=rel["to_column"],
            from_cardinality="Many",
            to_cardinality="One",
            cross_filtering_behavior="OneDirection",
            is_active=True
        )

print("All relationships successfully applied to SM_Gold!")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
