-- 1. Monthly Revenue Analysis
-- Tujuan:
-- Menghitung total pendapatan untuk setiap bulan berdasarkan tanggal transaksi.
SELECT 
  EXTRACT('year' FROM "InvoiceDate") AS "year",
  EXTRACT('month' FROM "InvoiceDate") AS "month",
  SUM("Quantity" * "UnitPrice") AS "total_revenue"
FROM online_retail
GROUP BY EXTRACT('month' FROM "InvoiceDate"), EXTRACT('year' FROM "InvoiceDate")
ORDER BY "year","month";

-- 2. Revenue Analysis by Country
-- Tujuan:
-- Menghitung total pendapatan dan jumlah transaksi untuk setiap negara.
SELECT 
  "Country",
  SUM("Quantity" * "UnitPrice") AS "total_revenue",
  COUNT(DISTINCT "InvoiceNo") AS "total_invoices"
FROM online_retail
GROUP BY "Country"
ORDER BY "total_revenue" DESC;

-- 3. Top Products by Revenue
-- Tujuan:
-- Mengidentifikasi produk dengan kontribusi pendapatan terbesar berdasarkan deskripsi produk.
SELECT
  "StockCode",
  "Description",
  SUM("Quantity") AS "totals_quantity",
  SUM("Quantity" * "UnitPrice") AS "total_revenue"
FROM online_retail
GROUP BY "StockCode","Description"
ORDER BY "total_revenue" DESC
LIMIT 10;

-- 4. Sales Analysis by Hour
-- Tujuan:
-- Mengidentifikasi jam dengan jumlah transaksi terbanyak berdasarkan waktu invoice.
SELECT
  EXTRACT('hour' FROM "InvoiceDate") AS "Hours",
  COUNT(DISTINCT "InvoiceNo") AS "total_invoices",
  SUM("Quantity" * "UnitPrice") AS "total_revenue"
FROM online_retail
GROUP BY EXTRACT('hour' FROM "InvoiceDate")
ORDER BY "total_invoices" DESC;

-- 5. Average Invoice Value by Country
-- Tujuan:
-- Menghitung rata-rata nilai invoice untuk setiap negara berdasarkan total nilai barang dalam setiap invoice.
SELECT 
  "Country",
  AVG("invoice_value") AS "average_invoice_value"
FROM (
  SELECT
    "Country",
    "InvoiceNo",
    SUM("Quantity" * "UnitPrice") AS "invoice_value"
  FROM online_retail
  GROUP BY "Country", "InvoiceNo"
) AS "invoice_summary"
GROUP BY "Country";

-- 6. Monthly Revenue Growth
-- Tujuan:
-- Membandingkan pendapatan setiap bulan dengan pendapatan bulan sebelumnya untuk melihat perubahan.
WITH monthly_revenue AS (
    SELECT
        EXTRACT('year' FROM "InvoiceDate") AS "year",
        EXTRACT('month' FROM "InvoiceDate") AS "month",
        SUM("Quantity" * "UnitPrice") AS "total_revenue"
    FROM online_retail
    GROUP BY
        EXTRACT('year' FROM "InvoiceDate"),
        EXTRACT('month' FROM "InvoiceDate")
)
SELECT *,
    LAG("total_revenue") OVER (
        ORDER BY "year", "month"
    ) AS "previous_month_revenue",
    "total_revenue" - LAG("total_revenue") OVER (
        ORDER BY "year", "month"
    ) AS "revenue_change"
FROM monthly_revenue
ORDER BY "year", "month";

-- 7. Monthly Revenue Growth Percentage
-- Tujuan:
-- Menghitung persentase perubahan pendapatan bulanan dibandingkan dengan bulan sebelumnya.
WITH monthly_revenue AS (
    SELECT
        EXTRACT('year' FROM "InvoiceDate") AS "year",
        EXTRACT('month' FROM "InvoiceDate") AS "month",
        SUM("Quantity" * "UnitPrice") AS "total_revenue"
    FROM online_retail
    GROUP BY
        EXTRACT('year' FROM "InvoiceDate"),
        EXTRACT('month' FROM "InvoiceDate")
)
SELECT
    *,
    LAG("total_revenue") OVER (
        ORDER BY "year", "month"
    ) AS "previous_month_revenue",
    "total_revenue" - LAG("total_revenue") OVER (
        ORDER BY "year", "month"
    ) AS "revenue_change",
    ROUND((
        (
            "total_revenue" - LAG("total_revenue") OVER (
                ORDER BY "year", "month"
            )
        )
        /
        NULLIF(
            LAG("total_revenue") OVER (
                ORDER BY "year", "month"
            ),
            0
        )
    ) * 100, 2) AS "growth(%)"

FROM monthly_revenue
ORDER BY "year", "month";



-- 8. Top 10 Products by Quantity Sold
-- Tujuan:
-- Mengidentifikasi 10 produk dengan jumlah unit terjual terbanyak berdasarkan data transaksi.
SELECT
  "StockCode",
  "Description",
  SUM("Quantity") AS "total_quantity",
  SUM("Quantity" * "UnitPrice") AS "total_revenue"
FROM online_retail
GROUP BY "StockCode","Description"
ORDER BY "total_quantity" DESC
LIMIT 10;

-- 9. Average Invoice Value by Month
-- Tujuan:
-- Menghitung rata-rata nilai invoice untuk setiap bulan guna memahami perubahan nilai belanja pelanggan.
WITH invoice_summary AS (
    SELECT
        EXTRACT('year' FROM "InvoiceDate") AS "year",
        EXTRACT('month' FROM "InvoiceDate") AS "month",
        "InvoiceNo",
        SUM("Quantity" * "UnitPrice") AS "invoice_value"
    FROM online_retail
    GROUP BY
        EXTRACT('year' FROM "InvoiceDate"),
        EXTRACT('month' FROM "InvoiceDate"),
        "InvoiceNo"
)
SELECT
    "year",
    "month",
    AVG("invoice_value") AS "average_invoice_value"
FROM invoice_summary
GROUP BY
    "year",
    "month"
ORDER BY
    "year",
    "month";


-- 10. CTE: Calculating Average Invoice Value by Country
-- Tujuan:
-- Menghitung rata-rata nilai transaksi untuk setiap negara dengan menjumlahkan Quantity * UnitPrice pada setiap invoice.
-- CTE digunakan untuk menghitung nilai setiap invoice terlebih dahulu, kemudian AVG digunakan untuk menghitung rata-rata nilai invoiceberdasarkan negara.
WITH invoice_summary AS (
  SELECT 
    "Country" ,
    "InvoiceNo",
    SUM("Quantity" * "UnitPrice") AS "invoice_value"
  FROM online_retail
  GROUP BY "Country","InvoiceNo"
)
SELECT 
  "Country",
  COUNT("InvoiceNo") AS "total_invoices",
  AVG("invoice_value") AS "average_invoice_value"
FROM "invoice_summary"
GROUP BY "Country"
ORDER BY "average_invoice_value" DESC
LIMIT 10;

-- 11. HAVING: Filtering Countries by Invoice Count
-- Tujuan:
-- Menampilkan negara yang memiliki lebih dari 100 invoice.
-- COUNT(DISTINCT "InvoiceNo") digunakan untuk menghitung jumlah invoice unik pada setiap negara.
-- HAVING digunakan untuk menyaring hasil agregasi berdasarkan jumlah invoice setelah GROUP BY dijalankan.
SELECT
  "Country",
  COUNT(DISTINCT "InvoiceNo") AS "total_invoices",
  SUM("Quantity"*"UnitPrice") AS "total_revenue"
FROM online_retail
GROUP BY "Country"
HAVING COUNT(DISTINCT "InvoiceNo") > 100
ORDER BY "total_revenue" DESC;

-- 12. Customer Revenue: Calculating Total Revenue per Customer
-- Tujuan:
-- Menghitung total revenue yang dihasilkan oleh setiap customer.
-- SUM digunakan untuk menjumlahkan nilai transaksi setiap customer.
-- GROUP BY digunakan untuk mengelompokkan transaksi berdasarkan CustomerID.
-- Customer tanpa CustomerID tidak disertakan dalam analisis ini.
SELECT 
  "CustomerID",
  SUM("Quantity"*"UnitPrice") AS "total_revenue"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "total_revenue" DESC;

-- 13. Top 10 Customers: Ranking Customers by Total Revenue
-- Tujuan:
-- Menampilkan 10 customer dengan total revenue tertinggi.
-- SUM digunakan untuk menghitung total revenue setiap customer.
-- ORDER BY digunakan untuk mengurutkan customer berdasarkan revenue  dari yang terbesar ke terkecil.
-- LIMIT digunakan untuk membatasi hasil menjadi 10 customer.
SELECT 
  "CustomerID",
  SUM("Quantity"*"UnitPrice") AS "total_revenue"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "total_revenue" DESC
LIMIT 10;

-- 14. Customer Product Variety: Counting Unique Products per Customer
-- Tujuan:
-- Menghitung jumlah jenis produk unik yang dibeli oleh setiap customer.
-- GROUP BY digunakan untuk mengelompokkan transaksi berdasarkan CustomerID.
-- Customer tanpa CustomerID tidak disertakan dalam analisis.
SELECT
  "CustomerID",
  SUM("Quantity") AS "total_quantity",
  COUNT(DISTINCT "StockCode") AS "total_unique_products"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "total_unique_products" DESC;

-- 15. Customer Purchase Frequency: Counting Invoices per Customer
-- Tujuan:
-- Menghitung jumlah invoice yang dimiliki oleh setiap customer.
-- COUNT(DISTINCT "InvoiceNo") digunakan untuk menghitung jumlah transaksi unik per customer.
-- GROUP BY digunakan untuk mengelompokkan transaksi berdasarkan CustomerID.
-- Customer tanpa CustomerID tidak disertakan dalam analisis.
SELECT 
  "CustomerID",
  COUNT(DISTINCT "InvoiceNo") AS "total_invoices"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "total_invoices" DESC;

-- 16. Repeat Customer Analysis: Identifying Returning Customers
-- Tujuan:
-- Mengidentifikasi customer yang melakukan pembelian lebih dari satu kali.
-- COUNT(DISTINCT "InvoiceNo") digunakan untuk menghitung jumlah invoice unik setiap customer.
-- HAVING digunakan untuk memilih customer yang memiliki lebih dari satu invoice.
-- Customer tanpa CustomerID tidak disertakan dalam analisis.
SELECT 
  "CustomerID",
  COUNT(DISTINCT "InvoiceNo") AS "total_invoices"  
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
HAVING COUNT(DISTINCT "InvoiceNo") > 1
ORDER BY "total_invoices" DESC;

-- 17. Window Function: Ranking Customers by Total Revenue
-- Tujuan:
-- Memberikan peringkat kepada setiap customer berdasarkan total revenue.
-- SUM digunakan untuk menghitung total revenue setiap customer.
-- RANK() digunakan untuk memberikan peringkat berdasarkan revenue dari yang terbesar ke terkecil.
-- Customer tanpa CustomerID tidak disertakan dalam analisis.
SELECT 
  "CustomerID",
  SUM("Quantity"*"UnitPrice") AS "total_revenue",
  RANK() OVER (ORDER BY (SUM("Quantity"*"UnitPrice")) DESC) AS "revenue_rank"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
GROUP BY "CustomerID"
ORDER BY "revenue_rank" ASC;

-- 18. Product Revenue Contribution: Calculating Revenue Percentage
-- Tujuan:
-- Menghitung kontribusi revenue setiap produk terhadap total revenue.
-- SUM digunakan untuk menghitung revenue setiap produk.
-- Persentase kontribusi dihitung dengan membagi revenue produk dengan total revenue seluruh produk, lalu dikalikan 100.
-- GROUP BY digunakan untuk mengelompokkan transaksi berdasarkan StockCode.
WITH product_revenue AS (
  SELECT
    "StockCode",
    "Description",
    SUM("Quantity" * "UnitPrice") AS "total_revenue"
  FROM online_retail
  GROUP BY "StockCode", "Description"
)
SELECT 
  "StockCode",
  "Description",
  "total_revenue",
  ROUND(("total_revenue"/SUM("total_revenue") OVER ())*100, 2) AS "revenue_percentage"
FROM product_revenue;

-- 19. Running Total Revenue: Calculating Cumulative Monthly Revenue
-- Tujuan:
-- Menghitung akumulasi revenue dari bulan ke bulan.
-- SUM digunakan untuk menghitung total revenue setiap bulan.
-- SUM() OVER digunakan untuk menghitung running total revenue.
-- ORDER BY pada window function memastikan akumulasi mengikuti urutan tahun dan bulan.
WITH revenue_month AS (
  SELECT
    EXTRACT ('year' FROM "InvoiceDate") AS "year",
    EXTRACT ('month' FROM "InvoiceDate") AS "month",
    SUM("Quantity"*"UnitPrice") AS "total_revenue"
  FROM online_retail
  GROUP BY
    EXTRACT('year' FROM "InvoiceDate"),
    EXTRACT('month' FROM "InvoiceDate")
)
SELECT *,
  SUM("total_revenue") OVER (ORDER BY "year", "month") AS "running_total_revenue"
FROM "revenue_month"
ORDER BY "year", "month";

-- 20. Sales KPI Summary: Creating an Overall Sales Summary
-- Tujuan:
-- Membuat ringkasan KPI utama dari dataset penjualan.
-- COUNT digunakan untuk menghitung jumlah baris transaksi.
-- COUNT(DISTINCT) digunakan untuk menghitung jumlah invoice unik, produk unik, dan customer yang teridentifikasi.
-- SUM digunakan untuk menghitung total quantity dan total revenue.
-- AVG digunakan untuk menghitung rata-rata nilai transaksi per invoice.
WITH invoice_summary AS (
    SELECT
        "InvoiceNo",
        SUM("Quantity" * "UnitPrice") AS "invoice_value"
    FROM online_retail
    GROUP BY "InvoiceNo"
),
kpi_summary AS (
    SELECT
        COUNT(*) AS "total_transactions",
        COUNT(DISTINCT "InvoiceNo") AS "total_invoices",
        COUNT(DISTINCT "StockCode") AS "total_unique_products",
        COUNT(DISTINCT "CustomerID") AS "total_customers",
        SUM("Quantity") AS "total_quantity",
        SUM("Quantity" * "UnitPrice") AS "total_revenue"
    FROM online_retail
)
SELECT
    *,
    (SELECT AVG("invoice_value") FROM invoice_summary)
        AS "average_invoice_value"
FROM kpi_summary;