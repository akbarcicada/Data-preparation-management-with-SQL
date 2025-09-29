select * from portofolio.order
order by row_id;

select * from portofolio.customer
order by row_id;

-- 1. Perbaikan format tanggal
ALTER TABLE portofolio.order
ALTER COLUMN order_date TYPE DATE
USING TO_DATE(order_date, 'DD-MM-YYYY');

-- 2. identifikasi dan hapus duplikasi berdasarkan primary key
-- versi khusus PostgreSQL
DELETE FROM portofolio.order a
USING portofolio.order b
WHERE a.row_id = b.row_id
AND a.ctid < b.ctid;

-- versi general (CTE)
WITH duplikasi AS
(
	SELECT row_id, ROW_NUMBER() OVER
	(PARTITION BY row_id ORDER BY row_id) AS a
	FROM portofolio.order
)
DELETE FROM portofolio.order
WHERE row_id IN (SELECT row_id FROM duplikasi WHERE a > 1);

-- 3. identifikasi nilai kosong pada kolom krusial
-- identifikasi
SELECT
SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS profit_kosong
, SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_kosong
, SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_kosong 
FROM portofolio.order o
JOIN portofolio.customer c ON o.row_id = c.row_id;

-- amputasi
DELETE FROM portofolio.order
WHERE profit IS NULL OR sales IS NULL;

-- 4. standarisasi nilai-nilai yang inkonsisten
UPDATE portofolio.customer
SET sub_category = INITCAP(sub_category);

-- 5. identifikasi nilai outlier pada kolom krusial
SELECT row_id, order_id, discount, profit 
FROM portofolio.order
WHERE discount >= 1 OR profit < -10000;
















