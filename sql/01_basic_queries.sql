
-- =====================================================
-- Project: E-commerce Sales & Customer Analytics
-- File: 01_basic_queries.sql
-- Purpose: Basic SQL queries for transaction data
-- Database: PostgreSQL
-- Table: online_retail
-- =====================================================


-- 1. SELECT: Menampilkan data transaksi
-- Tujuan: Memahami struktur dan isi tabel transaksi.

SELECT
    "InvoiceNo",
    "Description",
    "Quantity",
    "UnitPrice",
    "Country"
FROM online_retail
LIMIT 10;

-- 2. WHERE: Filtering Data by Country
-- Tujuan:
-- Menampilkan maksimal 10 transaksi yang berasal dari negara Germany.
SELECT
    "InvoiceNo",
    "Description",
    "Quantity",
    "UnitPrice",
    "Country"
FROM online_retail
WHERE "Country" = 'Germany'
LIMIT 10;

-- 3. ORDER BY: Sorting Data by Unit Price
-- Tujuan:
-- Menampilkan 10 transaksi dengan harga satuan tertinggi dalam dataset.
SELECT 
  "InvoiceNo",
  "Description",
  "Quantity",
  "UnitPrice",
  "Country"
FROM online_retail
ORDER BY "UnitPrice" DESC
LIMIT 10;

-- 4. DISTINCT: Retrieving Unique Countries
-- Tujuan:
-- Menampilkan daftar negara yang tercatat dalam dataset tanpa pengulangan nama negara.
SELECT DISTINCT "Country"
FROM online_retail
ORDER BY "Country" ASC ;

-- 5. WHERE with AND: Filtering Multiple Conditions
-- Tujuan:
-- Menampilkan maksimal 10 transaksi dari Germany dengan Quantity lebih dari 5.
SELECT 
  "InvoiceNo",
  "Description",
  "Quantity",
  "UnitPrice",
  "Country"
FROM online_retail
WHERE "Country" = 'Germany' AND "Quantity" > 5
LIMIT 10;

-- 6. WHERE with OR: Filtering Multiple Alternatives
-- Tujuan:
-- Menampilkan maksimal 10 transaksi yang berasal  dari Germany atau France.
SELECT 
  "InvoiceNo",
  "Description",
  "Quantity",
  "UnitPrice",
  "Country"
FROM online_retail
WHERE ("Country" = 'Germany' OR "Country" = 'France')
LIMIT 10;

-- 7. BETWEEN: Filtering Values Within a Range
-- Tujuan:
-- Menampilkan maksimal 10 baris dengan UnitPrice antara 5 dan 20, termasuk kedua batas.
SELECT 
  "UnitPrice"
FROM online_retail
WHERE "UnitPrice" BETWEEN 5 AND 20
LIMIT 10;

-- 8. LIKE: Pattern Matching in Product Descriptions
-- Tujuan:
-- Menampilkan maksimal 10 produk dengan deskripsi yang mengandung teks 'RED'.
SELECT
  "StockCode",
  "Description"
FROM online_retail
WHERE "Description" LIKE '%RED%'
LIMIT 10;

-- 9. IS NULL: Identifying Missing Customer IDs
-- Tujuan:
-- Menampilkan maksimal 10 transaksi yang tidak memiliki CustomerID.
SELECT
  "InvoiceNo",
  "CustomerID",
  "Country"
FROM online_retail
WHERE "CustomerID" IS NULL
LIMIT 10;

-- 10. IS NOT NULL: Identifying Known Customers
-- Tujuan:
-- Menampilkan maksimal 10 transaksi yang memiliki CustomerID.
SELECT
  "InvoiceNo",
  "CustomerID",
  "Country"
FROM online_retail
WHERE "CustomerID" IS NOT NULL
LIMIT 10;

-- 11. COUNT: Counting Transaction Rows
-- Tujuan:
-- Menghitung jumlah seluruh baris dalam tabel transaksi.
SELECT COUNT(*) AS "total_rows"
FROM online_retail;

-- 12. COUNT DISTINCT: Counting Unique Invoices
-- Tujuan:
-- Menghitung jumlah nomor invoice yang unik dalam tabel transaksi.
SELECT COUNT(DISTINCT"InvoiceNo") AS "total_invoices"
FROM online_retail;

-- 13. SUM: Calculating Total Units Sold
-- Tujuan:
-- Menghitung total kuantitas barang pada seluruh baris transaksi dalam dataset.
SELECT SUM("Quantity") AS "total_units_sold"
FROM online_retail;

-- 14. SUM with Calculation: Calculating Total Revenue
-- Tujuan:
-- Menghitung total pendapatan dari seluruh transaksi dengan mengalikan Quantity dan UnitPrice.
SELECT SUM("Quantity"*"UnitPrice") AS "total_revenue"
FROM online_retail;

-- 15. AVG: Calculating Average Unit Price
-- Tujuan:
-- Menghitung rata-rata harga satuan produk pada seluruh baris transaksi dalam dataset.
SELECT AVG("UnitPrice") AS "average_unit_price"
FROM online_retail;

-- 16. GROUP BY: Calculating Total Revenue by Country
-- Tujuan:
-- Menghitung total revenue untuk setiap negara dengan menjumlahkan hasil perkalian Quantity dan UnitPrice.
-- GROUP BY digunakan untuk mengelompokkan transaksi berdasarkan negara.
SELECT 
  "Country",
  SUM("Quantity"*"UnitPrice") AS "total_revenue"
FROM online_retail
GROUP BY "Country";

-- 17. ORDER BY: Ranking Countries by Total Revenue
-- Tujuan:
-- Mengurutkan negara berdasarkan total revenue dari nilai terbesar hingga terkecil.
-- ORDER BY digunakan untuk menentukan urutan hasil, Sedangkan DESC mengurutkan data secara menurun.
SELECT 
  "Country",
  SUM("Quantity"*"UnitPrice") AS "total_revenue"
FROM online_retail
GROUP BY "Country"
ORDER BY "total_revenue" DESC;

-- 18. COUNT DISTINCT: Calculating Total Invoices by Country
-- Tujuan:
-- Menghitung jumlah invoice unik pada setiap negara.
-- COUNT(DISTINCT) digunakan agar invoice yang muncul pada beberapa baris transaksi hanya dihitung satu kali.
-- GROUP BY digunakan untuk mengelompokkan hasil perhitungan berdasarkan negara.
SELECT 
  "Country",
  COUNT(DISTINCT"InvoiceNo") AS "total_invoices"
FROM online_retail
GROUP BY "Country";

-- 19. Subquery: Calculating Average Invoice Value by Country
-- Tujuan:
-- Menghitung total nilai setiap invoice terlebih dahulu, kemudian menghitung rata-rata nilai invoice untuk setiap negara menggunakan fungsi AVG().
-- Subquery digunakan untuk merangkum transaksi per invoice, sedangkan alias invoice_summary menjadi nama sementara untuk hasil subquery tersebut.
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

-- 20. HAVING: Filtering Countries by Invoice Count
-- Tujuan:
-- Menampilkan negara yang memiliki lebih dari 100 invoice unik.
-- GROUP BY digunakan untuk mengelompokkan data berdasarkan negara, sedangkan HAVING menyaring hasil agregasi berdasarkan jumlah invoice unik pada setiap negara.
SELECT
  "Country",
  COUNT(DISTINCT"InvoiceNo") AS "total_invoices"
FROM online_retail
GROUP BY "Country"
HAVING COUNT(DISTINCT"InvoiceNo") > 100;

-- 21. CASE WHEN: Categorizing Transaction Revenue
-- Tujuan:
-- Mengelompokkan nilai revenue pada setiap baris transaksi ke dalam kategori High, Medium, dan Low berdasarkan hasil perkalian Quantity dengan UnitPrice.
-- CASE WHEN digunakan untuk menentukan kategori berdasarkan kondisi yang telah ditetapkan.
SELECT 
  "InvoiceNo",
  ("Quantity"*"UnitPrice") AS "revenue",
  CASE 
    WHEN ("Quantity" * "UnitPrice") > 100 THEN 'High'
    WHEN ("Quantity" * "UnitPrice") >= 20 AND ("Quantity" * "UnitPrice") <= 100 THEN 'Medium'
    WHEN ("Quantity" * "UnitPrice") < 20 THEN 'Low'
  END AS "revenue_category"
FROM online_retail
LIMIT 20;

-- 22. CASE WHEN: Categorizing Countries by Invoice Count
-- Tujuan:
-- Mengelompokkan negara berdasarkan jumlah invoice unik ke dalam kategori High, Medium, dan Low.
-- COUNT(DISTINCT) digunakan untuk menghitung invoice unik, sedangkan CASE WHEN menentukan kategori berdasarkan jumlah invoice pada setiap negara.
SELECT 
  "Country",
  CASE 
    WHEN (COUNT(DISTINCT "InvoiceNo")) > 1000 THEN 'High'
    WHEN (COUNT(DISTINCT "InvoiceNo")) >= 100 AND (COUNT(DISTINCT "InvoiceNo")) <= 1000 THEN 'Medium'
    WHEN (COUNT(DISTINCT "InvoiceNo")) < 100 THEN 'Low'
  END as "invoice_category"
FROM online_retail
GROUP BY "Country";

-- 23. COALESCE: Replacing NULL Customer IDs
-- Tujuan:
-- Mengganti nilai CustomerID yang NULL dengan teks 'Unknown' agar data pelanggan yang tidak teridentifikasi dapat ditampilkan dengan keterangan yang lebih jelas.
-- CAST digunakan untuk mengubah CustomerID menjadi teks agar kompatibel dengan nilai pengganti 'Unknown'
SELECT 
  "InvoiceNo",
  COALESCE(CAST("CustomerID" AS VARCHAR), 'Unknown') AS "customer_id_display"
FROM online_retail
WHERE "CustomerID" IS NULL
LIMIT 20;

-- 24. ROUND: Rounding Transaction Revenue
-- Tujuan:
-- Menghitung revenue pada setiap baris transaksi dengan mengalikan Quantity dan UnitPrice, kemudian membulatkan hasilnya menjadi dua angka desimal menggunakan ROUND().
SELECT 
  "InvoiceNo",
  ROUND("Quantity" * "UnitPrice",2) AS "revenue_rounded"
FROM online_retail
LIMIT 20;

-- 25. MIN and MAX: Finding Minimum and Maximum Unit Price
-- Tujuan:
-- Mengetahui harga satuan terendah dan tertinggi pada
-- seluruh data transaksi menggunakan fungsi MIN() dan MAX().
SELECT 
  MIN("UnitPrice") AS "minimum_unit_price",
  MAX("UnitPrice") AS "maximum_unit_price"
FROM online_retail;