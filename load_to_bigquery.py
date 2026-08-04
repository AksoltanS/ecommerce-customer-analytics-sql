"""
Load Olist CSV files into BigQuery.

Usage:
    python3 load_to_bigquery.py
"""

import pandas as pd
from google.cloud import bigquery
from pathlib import Path

# --- CONFIG ---
PROJECT_ID = "aks-sql-analytics"
DATASET_ID = "olist"
RAW_DATA_DIR = Path("data/raw")

# Map filenames -> clean BigQuery table names
FILE_TO_TABLE = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "product_category_translation",
}


def main():
    client = bigquery.Client(project=PROJECT_ID)

    for filename, table_name in FILE_TO_TABLE.items():
        file_path = RAW_DATA_DIR / filename

        if not file_path.exists():
            print(f"⚠️  Skipping {filename} — file not found at {file_path}")
            continue

        print(f"Loading {filename} -> {DATASET_ID}.{table_name} ...")

        df = pd.read_csv(file_path)

        table_id = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"

        job_config = bigquery.LoadJobConfig(
            write_disposition="WRITE_TRUNCATE",
            autodetect=True,
        )

        job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
        job.result()

        table = client.get_table(table_id)
        print(f"   Loaded {table.num_rows} rows into {table_id}")

    print("\nAll done. Tables loaded into BigQuery dataset:", f"{PROJECT_ID}.{DATASET_ID}")


if __name__ == "__main__":
    main()
