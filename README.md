# E-commerce Customer Segmentation Using RFM and K-Means

An end-to-end data science project that applies customer analytics and unsupervised machine learning to segment e-commerce customers based on their purchasing behavior.

The project uses Python, RFM analysis, feature engineering, and K-Means clustering to identify distinct customer groups and derive insights that can support data-driven customer retention and marketing strategies.

## Project Overview

Understanding customer purchasing behavior is essential for developing effective customer retention strategies. This project analyzes historical e-commerce transaction data and applies unsupervised machine learning to identify groups of customers with similar purchasing patterns.

Customer behavior is represented using Recency, Frequency, and Monetary (RFM) metrics. These features are transformed and standardized before being used as inputs for the K-Means clustering algorithm.

## Objectives

- Understand customer purchasing behavior through exploratory data analysis (EDA).
- Calculate customer-level Recency, Frequency, and Monetary metrics.
- Perform feature engineering and prepare RFM features for clustering.
- Apply K-Means clustering to identify distinct customer segments.
- Evaluate clustering performance using the Silhouette Score and the Elbow Method.
- Interpret customer segments and develop potential business recommendations.

## Tools and Technologies

- **Programming Language:** Python
- **Data Manipulation:** Pandas, NumPy
- **Data Visualization:** Matplotlib, Seaborn
- **Machine Learning:** Scikit-learn
- **Database Querying:** PostgreSQL
- **Development Environment:** Google Colab, VS Code

## Dataset

This project uses the Online Retail dataset, which contains historical transaction records from December 2010 to December 2011.

The original dataset contains 541,909 records and 8 columns. Following data cleaning, the main transaction dataset contains **524,878 records**.

The dataset includes invoice numbers, product information, quantities, invoice dates, unit prices, customer identifiers, and countries.

The original Excel dataset is not required to reproduce the downstream analysis when the provided cleaned data and derived RFM files are available.

### Data Files

- `online_retail_cleaned.csv`: cleaned transaction-level dataset.
- `rfm_original.csv`: customer-level RFM metrics before transformation and standardization.
- `rfm_modeling.csv`: processed RFM features used for K-Means clustering.
- `rfm_customer_segments.csv`: customer RFM metrics with assigned cluster labels.

## Project Workflow

### 1. Data Understanding and Cleaning

The initial dataset was inspected to understand its structure, data types, missing values, duplicate records, and transaction anomalies.

The cleaning process included removing duplicate records, separating cancellation transactions, handling negative quantities and invalid unit prices, assessing missing values, and adjusting data types.

The resulting main dataset contains **524,878 records**.

### 2. Exploratory Data Analysis (EDA)

EDA was conducted to understand transaction patterns, sales performance, product performance, country-level revenue, and customer purchasing behavior.

Key findings include:

- Total recorded revenue: **£10,642,110.80**.
- Total quantity: **5,572,420 units**.
- Unique invoices: **19,960**.
- The United Kingdom contributes the largest share of recorded revenue.
- December 2011 covers only part of the month and is not directly comparable with a complete month.

### 3. RFM Analysis and Feature Engineering

Customer purchasing behavior was represented using three RFM metrics:

- **Recency:** Number of days since the customer's most recent transaction.
- **Frequency:** Number of unique invoices associated with the customer.
- **Monetary:** Total recorded transaction value associated with the customer.

The analysis includes **4,338 customers with an available CustomerID**.

Frequency and Monetary were log-transformed, and the three RFM features were standardized before clustering to prepare them for the K-Means algorithm.

### 4. Customer Segmentation Using K-Means

K-Means clustering was applied to group customers based on their processed RFM features.

Candidate cluster counts were assessed using the Elbow Method and Silhouette Score. The selected model uses **3 clusters**, achieving a Silhouette Score of **0.4157**.

The resulting segments exhibit different purchasing patterns:

- **Cluster 0:** Moderate recency and relatively low purchase frequency.
- **Cluster 1:** Longer recency and relatively low purchase frequency.
- **Cluster 2:** More recent purchases, higher purchase frequency, and higher cumulative monetary value.

These clusters provide a data-driven view of customer behavior. The cluster labels represent groups identified by the algorithm rather than predefined customer categories.

### 5. Cluster Interpretation and Business Recommendations

The identified customer segments can support the development of differentiated customer strategies.

Potential recommendations include:

- **Repeat Purchase Engagement:** Test relevant promotions and product recommendations to encourage repeat purchases.
- **Customer Reactivation:** Test reactivation campaigns for customers with longer recency.
- **Customer Retention:** Evaluate retention initiatives for customers with higher purchase frequency and monetary value.

These recommendations are hypotheses based on historical transaction patterns. Their effectiveness should be evaluated using campaign outcomes and, where possible, comparison groups.

## Repository Structure

```text
ecommerce-sales-customer-analytics/
├── data/
│   ├── online_retail_cleaned.csv
│   ├── rfm_original.csv
│   ├── rfm_modeling.csv
│   └── rfm_customer_segments.csv
├── notebooks/
│   ├── 01_data_understanding_cleaning.ipynb
│   ├── 02_eda_feature_engineering.ipynb
│   └── 03_customer_segmentation_modeling.ipynb
├── sql/
│   ├── 01_basic_queries.sql
│   ├── 02_sales_analysis.sql
│   └── 03_customer_analysis.sql
└── README.md
```

## Limitations

- The dataset covers December 2010 to December 2011 and represents historical purchasing behavior.
- Customers without a CustomerID are excluded from customer-level RFM analysis.
- Cancellation transactions are separated rather than fully reconciled against their original sales.
- Extreme transaction values may influence monetary metrics and customer segmentation.
- Recorded revenue should not be interpreted as accounting-verified net revenue.
- The Silhouette Score provides an indication of cluster separation, but it does not establish that the selected segmentation is optimal for every business objective.
- Clustering identifies patterns in historical data; it does not predict future customer behavior or prove that a marketing strategy will improve business outcomes.

## Conclusion

This project demonstrates an end-to-end data science workflow, from data understanding and exploratory analysis to feature engineering, unsupervised machine learning, model evaluation, and customer segment interpretation.

By combining RFM analysis with K-Means clustering, the project identifies distinct customer purchasing patterns that can inform further customer analytics and retention experiments.

The project also demonstrates practical experience with Python, SQL, data preprocessing, feature engineering, clustering evaluation, and communicating machine learning results in a business context.

## Future Improvements

- Compare K-Means with alternative clustering algorithms.
- Evaluate cluster stability and sensitivity to feature selection and scaling.
- Develop a repeatable pipeline for assigning segments to new customer data.
- Validate customer retention recommendations using subsequent transaction data.
- Develop an interactive dashboard to communicate customer segment characteristics.

## Dashboard

**Coming soon.**

An interactive dashboard may be added to present sales trends and customer segmentation results.
