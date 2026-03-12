-- Certification: DataCamp Associate Data Analyst in SQL
-- Practical Exam Queries

-- Task 1: Count products with missing year_added

SELECT 
    COUNT(*) AS missing_year
FROM 
    products
WHERE 
    year_added IS NULL;

-- Task 2: Clean and validate the products data

WITH brand_value AS (
    SELECT
        DISTINCT brand
    FROM
        products
    WHERE
        brand IS NOT NULL
    ORDER BY
        brand DESC
    LIMIT 7
	),

median_weight AS (
    SELECT
        ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY weight)::numeric, 2) AS median
    FROM (
        SELECT
            CASE
                WHEN weight ~ '^[0-9]+(\.[0-9]+)? grams$'
                THEN ROUND(LEFT(weight, POSITION(' ' IN weight)-1)::numeric, 2)
                WHEN weight ~ '^[0-9]+(\.[0-9]+)?$'
                THEN ROUND(weight::numeric, 2)
                ELSE NULL
            END AS weight
        FROM
            products
		) AS products_sub
	),

median_price AS (
    SELECT
        ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY price)::numeric, 2) AS median
    FROM
        products
	)
	
SELECT
    product_id,
    CASE
        WHEN product_type NOT IN ('Produce', 'Meat', 'Dairy', 'Bakery', 'Snacks') OR product_type IS NULL
        THEN 'Unknown'
        ELSE product_type
    END AS product_type,
    CASE
        WHEN brand NOT IN (SELECT brand FROM brand_value) OR brand IS NULL
        THEN 'Unknown'
        ELSE brand
    END AS brand,
    CASE
        WHEN weight ~ '^[0-9]+(\.[0-9]+)? grams$'
        THEN ROUND(LEFT(weight, POSITION(' ' IN weight)-1)::numeric, 2)
        WHEN weight ~ '^[0-9]+(\.[0-9]+)?$'
        THEN ROUND(weight::numeric, 2)
        ELSE (SELECT median FROM median_weight)
    END AS weight,
    CASE
        WHEN price IS NULL
        THEN (SELECT median FROM median_price)
        ELSE ROUND(price::numeric, 2)
    END AS price,
    COALESCE(average_units_sold, 0) AS average_units_sold,
    COALESCE(year_added, 2022) AS year_added,
    CASE
        WHEN stock_location ILIKE 'A' THEN 'A'
        WHEN stock_location ILIKE 'B' THEN 'B'
        WHEN stock_location ILIKE 'C' THEN 'C'
        WHEN stock_location ILIKE 'D' THEN 'D'
        ELSE 'Unknown'
    END AS stock_location
FROM
    products;

-- Task 3: Find the minimum and maximum price by product type
SELECT
    product_type,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM
    products
GROUP BY
    product_type;

-- Task 4: Return meat and dairy products with average_units_sold > 10
SELECT
    product_id,
    price,
    average_units_sold
FROM
    products
WHERE
    average_units_sold > 10
    AND product_type IN ('Meat', 'Dairy');