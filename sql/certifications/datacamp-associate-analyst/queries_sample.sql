-- Certification: DataCamp Associate Data Analyst in SQL
-- Sample Exam Queries

-- Task 1: Clean and validate the pet_supplies data

WITH median_sales AS (
	SELECT 
		ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY sales) :: numeric, 2) AS median
	FROM 
		pet_supplies 
	)

SELECT 
	product_id,
	CASE
		WHEN category NOT IN ('Housing', 'Food', 'Toys', 'Equipment', 'Medicine', 'Accessory') OR category IS NULL
		THEN 'Unknown' 
		ELSE category 
	END AS category,
	CASE 
		WHEN animal NOT IN ('Dog', 'Cat', 'Fish', 'Bird') OR animal IS NULL
		THEN 'Unknown' 
		ELSE animal 
	END AS animal,
	CASE 
		WHEN size ILIKE 'small' THEN 'Small'
		WHEN size ILIKE 'medium' THEN 'Medium'
		WHEN size ILIKE 'large' THEN 'Large'
		ELSE 'Unknown' 
	END AS size,
	CASE 
		WHEN price !~ '^[0-9]+(\.[0-9]+)?$' THEN 0 
		ELSE ROUND(CAST(price AS numeric), 2) END AS price,
	CASE 
		WHEN sales IS NULL THEN (SELECT median FROM median_sales)
		ELSE ROUND(CAST(sales AS numeric), 2) 
	END AS sales,
	COALESCE(rating, 0) AS rating,
	repeat_purchase
FROM 
	pet_supplies
WHERE 
	repeat_purchase IS NOT NULL;

-- Task 2: Compare sales for repeat purchases by animal

SELECT 
	animal, 
	repeat_purchase, 
	ROUND(AVG(sales::numeric), 0) AS avg_sales, 
	ROUND(MIN(sales::numeric), 0) AS min_sales, 
	ROUND(MAX(sales::numeric), 0) AS max_sales
FROM 
	pet_supplies
GROUP BY 
	animal, 
	repeat_purchase
ORDER BY 
	animal, 
	repeat_purchase;

-- Task 3: Return cat and dog products with repeat purchases
SELECT 
	product_id, 
	sales,
	rating
FROM 
	pet_supplies
WHERE 
	animal IN ('Cat', 'Dog')
	AND repeat_purchase = 1
ORDER BY 
	sales DESC;