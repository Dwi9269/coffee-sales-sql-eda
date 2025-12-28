DROP TABLE IF EXISTS public.coffee_sales;
CREATE TABLE public.coffee_sales (
  transaction_id      BIGINT,
  transaction_date    DATE,
  transaction_time    TIME,
  transaction_qty     INTEGER,
  store_id            INTEGER,
  store_location      TEXT,
  product_id          INTEGER,
  unit_price          NUMERIC(10,2),
  product_category    TEXT,
  product_type        TEXT,
  product_detail      TEXT
);

SELECT COUNT(*) FROM public.coffee_sales;
SELECT * FROM public.coffee_sales LIMIT 5;

-- 1) total baris
SELECT COUNT(*) AS total_rows
FROM public.coffee_sales;

-- 2) cek null kolom penting
SELECT
  SUM((transaction_id IS NULL)::int)   AS null_transaction_id,
  SUM((transaction_date IS NULL)::int) AS null_transaction_date,
  SUM((transaction_time IS NULL)::int) AS null_transaction_time,
  SUM((transaction_qty IS NULL)::int)  AS null_transaction_qty,
  SUM((unit_price IS NULL)::int)       AS null_unit_price
FROM public.coffee_sales;

-- 3) cek range qty & harga
SELECT
  MIN(transaction_qty) AS min_qty,
  MAX(transaction_qty) AS max_qty,
  MIN(unit_price)      AS min_price,
  MAX(unit_price)      AS max_price
FROM public.coffee_sales;


-- 2) ANALISIS DASAR
-- 2.1 Produk dengan jumlah penjualan terbanyak (pakai total qty)
SELECT
  product_detail,
  SUM(transaction_qty) AS total_qty
FROM public.coffee_sales
GROUP BY product_detail
ORDER BY total_qty DESC
LIMIT 10;

-- 2.2 Total pendapatan harian
SELECT
  transaction_date,
  SUM(transaction_qty * unit_price) AS daily_revenue
FROM public.coffee_sales
GROUP BY transaction_date
ORDER BY transaction_date;

-- 2.3 Kategori produk dengan pendapatan tertinggi
SELECT
  product_category,
  SUM(transaction_qty * unit_price) AS revenue
FROM public.coffee_sales
GROUP BY product_category
ORDER BY revenue DESC;

-- 2.4 Rata-rata transaksi per hari (jumlah transaksi/row per hari)
SELECT AVG(cnt) AS avg_transactions_per_day
FROM (
  SELECT transaction_date, COUNT(*) AS cnt
  FROM public.coffee_sales
  GROUP BY transaction_date
) x;

-- 2.5 Pola jam penjualan (jam mana revenue tertinggi)
SELECT
  EXTRACT(HOUR FROM transaction_time) AS hour,
  SUM(transaction_qty * unit_price) AS revenue
FROM public.coffee_sales
GROUP BY hour
ORDER BY revenue DESC;

-- 2.6 Tren penjualan berdasarkan hari dalam seminggu
SELECT
  EXTRACT(ISODOW FROM transaction_date) AS dow_num,   -- 1=Mon .. 7=Sun
  TO_CHAR(transaction_date, 'Day') AS day_name,
  SUM(transaction_qty * unit_price) AS revenue
FROM public.coffee_sales
GROUP BY dow_num, day_name
ORDER BY dow_num;



-- =========================================================
-- 3) ANALISIS TAMBAHAN (GROUP BY + HAVING)
-- =========================================================

-- 3.1 Hari dengan transaksi sangat ramai (contoh threshold 1000)
SELECT
  transaction_date,
  COUNT(*) AS total_transactions
FROM public.coffee_sales
GROUP BY transaction_date
HAVING COUNT(*) > 1000
ORDER BY total_transactions DESC;

-- 3.2 Produk dengan revenue besar (contoh threshold 50000)
SELECT
  product_detail,
  SUM(transaction_qty * unit_price) AS revenue
FROM public.coffee_sales
GROUP BY product_detail
HAVING SUM(transaction_qty * unit_price) > 5000
ORDER BY revenue DESC;

