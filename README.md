# E-Commerce Customer Analytics (SQL / BigQuery)

A SQL-first analytics project built on the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), analyzed entirely in **Google BigQuery**. The project covers data quality validation, cohort retention, RFM customer segmentation, delivery performance, and the relationship between delivery delay and customer satisfaction.

- **BigQuery** — cloud data warehouse, all analysis done in SQL
- **Python (pandas, google-cloud-bigquery)** — used only to load raw CSVs into BigQuery tables


## Project structure
```
ecommerce-customer-analytics-sql/
├── sql/
│   ├── schema_exploration.sql
│   ├── data_quality_checks.sql
│   ├── cohort_retention.sql
│   ├── segmentation.sql
│   ├── delivery_performance_by_region.sql
│   ├── review_score_by_drivers.sql
│   └── seller_performance_panel.sql
├── load_to_bigquery.py
├── writeup.md
└── README.md
```

Each query is self-contained and can be run independently in any order. For a suggested reading order that tells a coherent business story, see below.

## Suggested reading order
1. `schema_exploration.sql` — get oriented with table sizes and structure
2. `data_quality_checks.sql` — validate the data, including a key gotcha: `customer_id` is unique per *order*, not per *person* (see note below)
3. `cohort_retention.sql` — first analytical finding: how well does Olist retain customers month over month?
4. `segmentation.sql` — RFM segmentation, reinforces the retention finding with a different lens
5. `delivery_performance_by_region.sql` — operational angle: where are deliveries slowest?
6. `review_score_by_drivers.sql` — the headline finding: does delivery delay hurt review scores?
7. `seller_performance_panel.sql` — same finding, validated at the seller level

## How to reproduce
1. Download the dataset via the Kaggle API:
   ```bash
   kaggle datasets download -d olistbr/brazilian-ecommerce -p data/raw --unzip
   ```
2. Set up a Google Cloud project and BigQuery dataset named `olist`.
3. Run `load_to_bigquery.py` to load all 9 CSVs into BigQuery tables.
4. Run the SQL files in `sql/` in the BigQuery console.

## Key findings
Headline finding: orders that arrive even 1-7 days late see review scores drop from ~4.3 to 2.71, and the % of low reviews (1-2 stars) jumps from ~9% to ~49% and delivery delay is the single strongest driver of customer dissatisfaction found in this analysis.
