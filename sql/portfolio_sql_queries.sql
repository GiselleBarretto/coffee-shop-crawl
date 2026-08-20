USE coffee_shop_crawl;

-- Query 1 -> Project KPIs.
SELECT COUNT(*) AS 'Total Coffee Shops',
	ROUND(AVG(rating),2) AS 'Average Rating',
    SUM(review_count) AS 'Number of Reviews',
    Round(AVG(review_count),2) AS 'AVG reviews per shop',
    COUNT(DISTINCT(zip_code)) AS 'Number of Distinct ZIP Codes'
FROM coffee_shops;

-- Query 2 -> Best Value Coffee Shops with rating greater than 4.2, and more than 100 reviews.
SELECT normalized_name,
	rating,
    review_count,
    price_tier,
    value_score,
    shop_type,
    zip_code
FROM coffee_shops
WHERE value_score IS NOT NULL
	AND rating >= 4.2
    AND REVIEW_COUNT >= 100
ORDER BY value_score DESC
LIMIT 10;

-- Query 3 -> Highly rated and well established coffee shops with reviews greater than 250 and rating > 4.5.
SELECT normalized_name,
	rating,
    review_count,
    price_tier,
    value_score,
    address
FROM coffee_shops
WHERE value_score IS NOT NULL
	AND review_count > 250
    AND rating >= 4.5
ORDER BY rating DESC, review_count DESC
LIMIT 10;

-- Query 4 -> Hidden Gems.
SELECT normalized_name,
	rating,
    review_count,
    price_tier,
    value_score,
    address
FROM coffee_shops
WHERE value_score IS NOT NULL
	AND hidden_gem = 'yes'
ORDER BY rating DESC, review_count DESC
LIMIT 10;

-- Query 5 -> Does price affect performance?
SELECT price_level, price_tier,
	COUNT(normalized_name) AS 'Number of coffee shops',
	ROUND(AVG(rating),2) AS 'AVG rating',
    ROUND(AVG(review_count),0) AS 'AVG review count',
    ROUND(AVG(value_score),2) AS 'AVG value score'
FROM coffee_shops
#WHERE price_tier != 'Unknown'
GROUP BY price_level, price_tier
ORDER BY price_level DESC, price_tier;

-- Query 6 -> Best ZIP codes for coffee.
SELECT zip_code,
	COUNT(normalized_name) AS 'Number of coffee shops',
	ROUND(AVG(rating),2) AS 'AVG rating',
    SUM(review_count) AS 'Total reviews', #we have used SUM(review_count) because we want to answer the question How much total customer engagement exists in this area?
    ROUND(AVG(value_score),2) AS 'Average value score'
FROM coffee_shops
WHERE value_score IS NOT NULL
	AND zip_code IS NOT NULL
GROUP BY zip_code
ORDER BY `AVG rating` DESC  #if your alias contains a space, use backticks(``) to reference it otherwise SQL will consider it a string.
LIMIT 10;

-- Query 7 -> Chains vs. independent coffee shops.
SELECT shop_type,
	COUNT(normalized_name) AS 'Number of coffee shops',
	ROUND(AVG(rating),2) AS 'AVG rating',
    ROUND(AVG(review_count),0) AS 'AVG number of reviews',
    ROUND(AVG(value_score),2) AS 'Average value score'
FROM coffee_shops
WHERE value_score IS NOT NULL
GROUP BY shop_type;

-- SELECT COUNT(normalized_name)
-- FROM coffee_shops
-- WHERE value_score IS NULL;

-- Query 8 -> Popular shops with room for improvement.
SELECT normalized_name AS 'Coffee shops',
	rating AS 'Ratings',
	review_count AS 'Number of reviews',
    price_tier,
    shop_type,
    address
FROM coffee_shops
WHERE review_count >= 300
	AND rating <= 4.0
ORDER BY review_count DESC
LIMIT 10;

SELECT *
FROM coffee_shops
WHERE normalized_name = 'colada shop';

-- Query 9 -> Rating distribution
SELECT rating_band,
	COUNT(*) AS shop_count,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS percentage_of_shops
FROM coffee_shops
WHERE rating IS NOT NULL
GROUP BY rating_band
ORDER BY
CASE rating_band
	WHEN 'Below 3.5' THEN 1
	WHEN '3.5-3.9' THEN 2
	WHEN '4.0-4.4' THEN 3
	WHEN '4.5-5.0' THEN 4
	ELSE 5
END;

-- Query 10 -> Most reviewed coffee shops
SELECT normalized_name AS 'Coffee shop name',
	rating AS 'Ratings',
	review_count AS 'Number of reviews',
    price_tier,
    shop_type,
    value_score,
    address
FROM coffee_shops
WHERE value_score IS NOT NULL
ORDER BY review_count DESC
LIMIT 10;

SELECT *
FROM coffee_shops;