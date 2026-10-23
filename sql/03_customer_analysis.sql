-- 1. Customer Revenue Analysis: Calculating Total Revenue per Customer
-- Tujuan:
-- Menghitung total revenue yang dihasilkan oleh setiap customer.
-- SUM menjumlahkan nilai transaksi, sedangkan GROUP BY mengelompokkan transaksi per CustomerID.
-- Customer tanpa CustomerID tidak disertakan.
--
SELECT
  "CustomerID",
  SUM("Quantity" * "UnitPrice") AS "total_revenue"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "total_revenue" DESC;


-- 2. Customer Purchase Frequency: Counting Invoices per Customer
-- Tujuan:
-- Menghitung jumlah invoice unik yang dimiliki setiap customer.
-- COUNT(DISTINCT "InvoiceNo") menghitung invoice unik per customer.
--
SELECT
  "CustomerID",
  COUNT(DISTINCT "InvoiceNo") AS "total_invoices"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "total_invoices" DESC;


-- 3. Average Invoice Value: Calculating Average Spending per Customer
-- Tujuan:
-- Menghitung rata-rata nilai invoice untuk setiap customer.
-- Nilai produk dijumlahkan per invoice terlebih dahulu, kemudian dirata-ratakan per customer.
--
WITH invoice_summary AS (
  SELECT
    "CustomerID",
    "InvoiceNo",
    SUM("Quantity" * "UnitPrice") AS "invoice_value"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID", "InvoiceNo"
)
SELECT
  "CustomerID",
  AVG("invoice_value") AS "average_invoice_value"
FROM invoice_summary
GROUP BY "CustomerID"
ORDER BY "average_invoice_value" DESC;


-- 4. Customer Recency: Finding the Last Purchase Date
-- Tujuan:
-- Mengetahui tanggal transaksi terakhir setiap customer.
-- MAX("InvoiceDate") mengambil tanggal transaksi paling baru.
--
SELECT
  "CustomerID",
  MAX("InvoiceDate") AS "last_purchase_date"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "last_purchase_date" DESC;


-- 5. Customer Product Diversity: Counting Distinct Products Purchased
-- Tujuan:
-- Menghitung jumlah jenis produk berbeda yang dibeli setiap customer.
-- COUNT(DISTINCT "StockCode") membantu melihat variasi produk yang dibeli customer.
--
SELECT
  "CustomerID",
  COUNT(DISTINCT "StockCode") AS "unique_products_purchased"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "unique_products_purchased" DESC;


-- 6. Customer Recency: Calculating Days Since Last Purchase
-- Tujuan:
-- Menghitung jumlah hari sejak transaksi terakhir setiap customer.
-- Tanggal acuan adalah 2011-12-10, sehari setelah transaksi terakhir dalam dataset.
--
WITH customer_last_purchase AS (
  SELECT
    "CustomerID",
    MAX("InvoiceDate") AS "last_purchase_date"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
)
SELECT
  "CustomerID",
  DATE '2011-12-10' - "last_purchase_date"::DATE AS "recency_days"
FROM customer_last_purchase
ORDER BY "recency_days" ASC;


-- 7. RFM Summary: Combining Customer Recency, Frequency, and Monetary
-- Tujuan:
-- Menggabungkan Recency, Frequency, dan Monetary untuk setiap customer.
-- Recency dihitung dari tanggal acuan dikurangi tanggal transaksi terakhir.
-- Frequency adalah jumlah invoice unik, sedangkan Monetary adalah total Quantity * UnitPrice.
--
WITH rfm_summary AS (
  SELECT
    "CustomerID",
    MAX("InvoiceDate") AS "last_purchase_date",
    COUNT(DISTINCT "InvoiceNo") AS "frequency",
    SUM("Quantity" * "UnitPrice") AS "monetary"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
)
SELECT
  "CustomerID",
  DATE '2011-12-10' - "last_purchase_date"::DATE AS "recency_days",
  "frequency",
  "monetary"
FROM rfm_summary
ORDER BY "recency_days" ASC;


-- 8. RFM Scoring: Assigning Scores to Customers
-- Tujuan:
-- Memberikan skor 1 sampai 5 untuk Recency, Frequency, dan Monetary.
-- Recency terkecil mendapatkan skor tertinggi.
-- Frequency dan Monetary terbesar mendapatkan skor tertinggi.
--
WITH rfm_summary AS (
  SELECT
    "CustomerID",
    MAX("InvoiceDate") AS "last_purchase_date",
    COUNT(DISTINCT "InvoiceNo") AS "frequency",
    SUM("Quantity" * "UnitPrice") AS "monetary"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
),
customer_recency AS (
  SELECT
    "CustomerID",
    DATE '2011-12-10' - "last_purchase_date"::DATE AS "recency_days",
    "frequency",
    "monetary"
  FROM rfm_summary
)
SELECT
  "CustomerID",
  "recency_days",
  "frequency",
  "monetary",
  NTILE(5) OVER (ORDER BY "recency_days" DESC) AS "r_score",
  NTILE(5) OVER (ORDER BY "frequency" ASC) AS "f_score",
  NTILE(5) OVER (ORDER BY "monetary" ASC) AS "m_score"
FROM customer_recency
ORDER BY "recency_days" ASC;


-- 9. RFM Score Combination: Combining Individual RFM Scores
-- Tujuan:
-- Menggabungkan skor Recency, Frequency, dan Monetary menjadi satu skor RFM.
-- Skor gabungan membantu membandingkan pola perilaku customer.
--
WITH rfm_summary AS (
  SELECT
    "CustomerID",
    MAX("InvoiceDate") AS "last_purchase_date",
    COUNT(DISTINCT "InvoiceNo") AS "frequency",
    SUM("Quantity" * "UnitPrice") AS "monetary"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
),
customer_recency AS (
  SELECT
    "CustomerID",
    DATE '2011-12-10' - "last_purchase_date"::DATE AS "recency_days",
    "frequency",
    "monetary"
  FROM rfm_summary
),
rfm_scoring AS (
  SELECT
    "CustomerID",
    "recency_days",
    "frequency",
    "monetary",
    NTILE(5) OVER (ORDER BY "recency_days" DESC) AS "r_score",
    NTILE(5) OVER (ORDER BY "frequency" ASC) AS "f_score",
    NTILE(5) OVER (ORDER BY "monetary" ASC) AS "m_score"
  FROM customer_recency
)
SELECT
  "CustomerID",
  "r_score",
  "f_score",
  "m_score",
  "r_score"::TEXT || "f_score"::TEXT || "m_score"::TEXT AS "rfm_score"
FROM rfm_scoring
ORDER BY "rfm_score" DESC;


-- 10. Customer Segmentation: Classifying Customers Based on RFM Scores
-- Tujuan:
-- Mengelompokkan customer berdasarkan kombinasi skor RFM.
-- Aturan segmen di bawah merupakan aturan analisis proyek, bukan kategori baku universal.
--
WITH rfm_summary AS (
  SELECT
    "CustomerID",
    MAX("InvoiceDate") AS "last_purchase_date",
    COUNT(DISTINCT "InvoiceNo") AS "frequency",
    SUM("Quantity" * "UnitPrice") AS "monetary"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
),
customer_recency AS (
  SELECT
    "CustomerID",
    DATE '2011-12-10' - "last_purchase_date"::DATE AS "recency_days",
    "frequency",
    "monetary"
  FROM rfm_summary
),
rfm_scoring AS (
  SELECT
    "CustomerID",
    "recency_days",
    "frequency",
    "monetary",
    NTILE(5) OVER (ORDER BY "recency_days" DESC) AS "r_score",
    NTILE(5) OVER (ORDER BY "frequency" ASC) AS "f_score",
    NTILE(5) OVER (ORDER BY "monetary" ASC) AS "m_score"
  FROM customer_recency
),
rfm_combination AS (
  SELECT
    "CustomerID",
    "r_score",
    "f_score",
    "m_score",
    "r_score"::TEXT || "f_score"::TEXT || "m_score"::TEXT AS "rfm_score"
  FROM rfm_scoring
)
SELECT
  "CustomerID",
  "r_score",
  "f_score",
  "m_score",
  "rfm_score",
  CASE
    WHEN "rfm_score" = '555' THEN 'Best Customers'
    WHEN "r_score" >= 4 AND "f_score" >= 4 AND "m_score" >= 3 THEN 'Loyal Customers'
    WHEN "r_score" <= 2 THEN 'At Risk / Inactive'
    ELSE 'Other Customers'
  END AS "customer_segment"
FROM rfm_combination
ORDER BY "rfm_score" DESC;


-- 11. Customer Revenue Ranking: Ranking Customers by Revenue
-- Tujuan:
-- Memberikan peringkat kepada customer berdasarkan total revenue.
-- Customer dengan revenue tertinggi mendapatkan peringkat teratas.
--
WITH customer_revenue AS (
  SELECT
    "CustomerID",
    SUM("Quantity" * "UnitPrice") AS "total_revenue"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
)
SELECT
  "CustomerID",
  "total_revenue",
  RANK() OVER (ORDER BY "total_revenue" DESC) AS "revenue_rank"
FROM customer_revenue
ORDER BY "revenue_rank" ASC;


-- 12. Customer Purchase Frequency Ranking: Ranking Customers by Invoice Count
-- Tujuan:
-- Memberikan peringkat kepada customer berdasarkan jumlah invoice unik.
-- RANK memberikan peringkat yang sama jika jumlah invoice sama.
--
WITH customer_frequency AS (
  SELECT
    "CustomerID",
    COUNT(DISTINCT "InvoiceNo") AS "total_invoices"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
)
SELECT
  "CustomerID",
  "total_invoices",
  RANK() OVER (ORDER BY "total_invoices" DESC) AS "purchase_rank"
FROM customer_frequency
ORDER BY "purchase_rank" ASC;


-- 13. Customer Revenue Contribution: Calculating Revenue Percentage
-- Tujuan:
-- Menghitung persentase kontribusi revenue setiap customer terhadap total revenue customer teridentifikasi.
--
WITH customer_revenue AS (
  SELECT
    "CustomerID",
    SUM("Quantity" * "UnitPrice") AS "total_revenue"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
)
SELECT
  "CustomerID",
  "total_revenue",
  ROUND(
    "total_revenue" / NULLIF(SUM("total_revenue") OVER (), 0) * 100,
    2
  ) AS "revenue_percentage"
FROM customer_revenue
ORDER BY "revenue_percentage" DESC;


-- 14. Customer Revenue Distribution: Counting Customers by Revenue Category
-- Tujuan:
-- Mengelompokkan customer berdasarkan total revenue dan menghitung jumlah customer per kategori.
-- Batas kategori adalah aturan analisis proyek dan dapat disesuaikan.
--
WITH customer_revenue AS (
  SELECT
    "CustomerID",
    SUM("Quantity" * "UnitPrice") AS "total_revenue"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
),
revenue_category_customer AS (
  SELECT
    "CustomerID",
    "total_revenue",
    CASE
      WHEN "total_revenue" >= 1000 THEN 'High Revenue'
      WHEN "total_revenue" >= 100 THEN 'Medium Revenue'
      ELSE 'Low Revenue'
    END AS "revenue_category"
  FROM customer_revenue
)
SELECT
  "revenue_category",
  COUNT(*) AS "total_customers"
FROM revenue_category_customer
GROUP BY "revenue_category"
ORDER BY
  CASE "revenue_category"
    WHEN 'Low Revenue' THEN 1
    WHEN 'Medium Revenue' THEN 2
    WHEN 'High Revenue' THEN 3
  END;


-- 15. Customer Revenue Ranking by Category: Ranking Within Revenue Categories
-- Tujuan:
-- Memberikan peringkat revenue kepada customer dalam kategori revenue masing-masing.
--
WITH customer_revenue AS (
  SELECT
    "CustomerID",
    SUM("Quantity" * "UnitPrice") AS "total_revenue"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
),
revenue_category_customer AS (
  SELECT
    "CustomerID",
    "total_revenue",
    CASE
      WHEN "total_revenue" >= 1000 THEN 'High Revenue'
      WHEN "total_revenue" >= 100 THEN 'Medium Revenue'
      ELSE 'Low Revenue'
    END AS "revenue_category"
  FROM customer_revenue
)
SELECT
  "CustomerID",
  "total_revenue",
  "revenue_category",
  RANK() OVER (
    PARTITION BY "revenue_category"
    ORDER BY "total_revenue" DESC
  ) AS "revenue_rank"
FROM revenue_category_customer
ORDER BY "revenue_category", "revenue_rank";


-- 16. Customer Average Quantity per Invoice: Measuring Purchase Volume
-- Tujuan:
-- Menghitung rata-rata jumlah unit produk per invoice untuk setiap customer.
-- Metrik ini berbeda dari revenue dan jumlah invoice.
--
WITH invoice_summary AS (
  SELECT
    "CustomerID",
    "InvoiceNo",
    SUM("Quantity") AS "invoice_quantity"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID", "InvoiceNo"
)
SELECT
  "CustomerID",
  AVG("invoice_quantity") AS "average_quantity_per_invoice"
FROM invoice_summary
GROUP BY "CustomerID"
ORDER BY "average_quantity_per_invoice" DESC;


-- 17. Customer Repeat Purchase Analysis: Counting One-Time and Repeat Customers
-- Tujuan:
-- Mengelompokkan customer menjadi one-time customer dan repeat customer.
-- Repeat customer adalah customer dengan lebih dari satu invoice unik.
--
WITH customer_frequency AS (
  SELECT
    "CustomerID",
    COUNT(DISTINCT "InvoiceNo") AS "total_invoices"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
),
customer_types AS (
  SELECT
    CASE
      WHEN "total_invoices" = 1 THEN 'One-time Customer'
      ELSE 'Repeat Customer'
    END AS "customer_type"
  FROM customer_frequency
)
SELECT
  "customer_type",
  COUNT(*) AS "total_customers"
FROM customer_types
GROUP BY "customer_type"
ORDER BY "customer_type";


-- 18. Repeat Customer Rate: Calculating the Percentage of Repeat Customers
-- Tujuan:
-- Menghitung jumlah customer, jumlah repeat customer, dan persentase repeat customer.
--
WITH customer_frequency AS (
  SELECT
    "CustomerID",
    COUNT(DISTINCT "InvoiceNo") AS "total_invoices"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
)
SELECT
  COUNT(*) AS "total_customers",
  COUNT(*) FILTER (WHERE "total_invoices" > 1) AS "repeat_customers",
  ROUND(
    COUNT(*) FILTER (WHERE "total_invoices" > 1)::NUMERIC
    / NULLIF(COUNT(*), 0) * 100,
    2
  ) AS "repeat_customer_rate"
FROM customer_frequency;


-- 19. Customer Purchase Behavior Summary: Summarizing Customer Activity
-- Tujuan:
-- Merangkum jumlah invoice, total revenue, dan rata-rata nilai invoice per customer.
-- Rata-rata dihitung dari nilai invoice, bukan dari nilai per baris produk.
--
WITH invoice_summary AS (
  SELECT
    "CustomerID",
    "InvoiceNo",
    SUM("Quantity" * "UnitPrice") AS "invoice_value"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID", "InvoiceNo"
),
customer_summary AS (
  SELECT
    "CustomerID",
    COUNT("InvoiceNo") AS "total_invoices",
    SUM("invoice_value") AS "total_revenue",
    AVG("invoice_value") AS "average_invoice_value"
  FROM invoice_summary
  GROUP BY "CustomerID"
)
SELECT
  "CustomerID",
  "total_invoices",
  "total_revenue",
  ROUND("average_invoice_value", 2) AS "average_invoice_value"
FROM customer_summary
ORDER BY "total_revenue" DESC;


-- 20. Customer Analysis KPI Summary: Summarizing Key Customer Metrics
-- Tujuan:
-- Merangkum jumlah customer, repeat customer rate, total revenue, dan rata-rata revenue per customer.
-- Metrik revenue hanya mencakup customer dengan CustomerID teridentifikasi.
--
WITH customer_summary AS (
  SELECT
    "CustomerID",
    COUNT(DISTINCT "InvoiceNo") AS "total_invoices",
    SUM("Quantity" * "UnitPrice") AS "total_revenue"
  FROM online_retail
  WHERE "CustomerID" IS NOT NULL
  GROUP BY "CustomerID"
)
SELECT
  COUNT(*) AS "total_customers",
  COUNT(*) FILTER (WHERE "total_invoices" > 1) AS "repeat_customers",
  ROUND(
    COUNT(*) FILTER (WHERE "total_invoices" > 1)::NUMERIC
    / NULLIF(COUNT(*), 0) * 100,
    2
  ) AS "repeat_customer_rate",
  SUM("total_revenue") AS "total_revenue",
  ROUND(AVG("total_revenue"), 2) AS "average_revenue_per_customer"
FROM customer_summary;
