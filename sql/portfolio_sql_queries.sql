USE coffee_shop_crawl;

-- ============================================================
-- Query 1: Overall project KPIs
-- ============================================================
-- Provides a high-level summary of the coffee-shop dataset.
-- Business question:
-- What does the coffee-shop market represented in this dataset
-- look like at a glance?

SELECT
    COUNT(*) AS total_shops,
    ROUND(AVG(rating), 2) AS average_rating,
    SUM(review_count) AS total_reviews,
    ROUND(AVG(review_count), 0) AS average_reviews_per_shop,
    COUNT(DISTINCT zip_code) AS areas_covered
FROM coffee_shops;


-- ============================================================
-- Query 2: Coffee shops offering the strongest overall value
-- ============================================================
-- Identifies shops that provide the strongest overall combination
-- of customer rating, review credibility, and affordability.
--
-- Shops without reported price information are excluded because
-- value for money cannot be evaluated without a price level.
--
-- Business question:
-- Which coffee shops provide the best balance of quality,
-- credibility, and price?

SELECT
    normalized_name,
    rating,
    review_count,
    price_tier,
    value_score,
    shop_type,
    zip_code
FROM coffee_shops
WHERE value_score IS NOT NULL
  AND review_count >= 50
ORDER BY value_score DESC
LIMIT 10;


-- ============================================================
-- Query 3: Highest-rated shops with reliable review evidence
-- ============================================================
-- Ranks the highest-rated coffee shops after requiring at least
-- 100 reviews. 
--
-- Shops are ranked first by rating. When two shops have the same
-- rating, the one with more reviews is ranked higher because its
-- rating is supported by a larger amount of customer feedback.
--
-- Business question:
-- Which highly rated coffee shops have enough reviews for their
-- ratings to be considered reasonably reliable?

SELECT
    normalized_name,
    rating,
    review_count,
    price_tier,
    shop_type,
    address
FROM coffee_shops
WHERE review_count >= 100
ORDER BY
    rating DESC,
    review_count DESC
LIMIT 10;


-- ============================================================
-- Query 4: Hidden gems
-- ============================================================
-- Returns coffee shops classified as hidden gems during the data-
-- preparation process.
--
-- In this project, a hidden gem is a strongly rated shop that has
-- received enough reviews to show meaningful customer interest,
-- but has not yet accumulated the very large review volume usually
-- associated with the most widely known businesses.
--
-- The results are ranked by rating and then by review count so that
-- the strongest-rated shops with the most supporting evidence appear
-- first.
--
-- Business question:
-- Which lesser-known coffee shops are performing exceptionally well
-- and may deserve greater attention?

SELECT
    normalized_name,
    rating,
    review_count,
    price_tier,
    value_score,
    address
FROM coffee_shops
WHERE hidden_gem = 'Yes'
ORDER BY
    rating DESC,
    review_count DESC;


-- ============================================================
-- Query 5: Price tier versus customer rating and value
-- ============================================================
-- Compares shop performance across the available price tiers.
-- For each tier, the query calculates the number of businesses,
-- average customer rating, average review count, and average Value
-- Score.
--
-- Shops without a reported price level are excluded because they
-- cannot be assigned to a valid price category.
--
-- Business question:
-- Do more expensive coffee shops receive better ratings, attract
-- more customer engagement, or deliver stronger overall value?

SELECT
    price_tier,
    COUNT(*) AS shop_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(review_count), 0) AS average_review_count,
    ROUND(AVG(value_score), 2) AS average_value_score
FROM coffee_shops
WHERE price_level IS NOT NULL
GROUP BY
    price_level,
    price_tier
ORDER BY price_level;


-- ============================================================
-- Query 6: Coffee-shop performance by ZIP-code area
-- ============================================================
-- Summarizes coffee-shop performance within each ZIP-code area.
-- The query reports the number of shops, average rating, combined
-- review volume, and average Value Score for each area.
--
-- Areas containing fewer than three shops are excluded. This avoids
-- drawing broad conclusions about a ZIP code based on only one or
-- two businesses.
--
-- Results are ordered by average Value Score to highlight areas where
-- customers appear to have access to the strongest overall mix of
-- quality, customer confidence, and affordability.
--
-- Business question:
-- Which ZIP-code areas offer the strongest overall coffee-shop
-- experience?

SELECT
    zip_code,
    COUNT(*) AS shop_count,
    ROUND(AVG(rating), 2) AS average_rating,
    SUM(review_count) AS total_reviews,
    ROUND(AVG(value_score), 2) AS average_value_score
FROM coffee_shops
WHERE zip_code IS NOT NULL
  AND TRIM(zip_code) <> ''
GROUP BY zip_code
HAVING COUNT(*) >= 3
ORDER BY average_value_score DESC;


-- ============================================================
-- Query 7: Chain versus independent coffee-shop performance
-- ============================================================
-- Compares chain locations with independent or local coffee shops.
-- The analysis considers the number of shops in each group, average
-- customer rating, average review volume, and average Value Score.
--
-- Business question:
-- How do chain coffee shops and independent shops differ in customer
-- satisfaction, popularity, and overall value?

SELECT
    shop_type,
    COUNT(*) AS shop_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(review_count), 0) AS average_review_count,
    ROUND(AVG(value_score), 2) AS average_value_score
FROM coffee_shops
GROUP BY shop_type
ORDER BY average_rating DESC;


-- ============================================================
-- Query 8: Popular but underperforming coffee shops
-- ============================================================
-- Identifies businesses with substantial customer engagement but
-- comparatively weak ratings.
--
-- A minimum of 300 reviews is used to represent meaningful popularity,
-- while a rating below 4.0 is used to flag businesses that may not be
-- meeting customer expectations as consistently as other shops in
-- the dataset.
--
-- The results are ordered by review count so that the most visible
-- and frequently reviewed underperforming businesses appear first.
--
-- Business question:
-- Which widely reviewed coffee shops may have the greatest opportunity
-- to improve customer satisfaction?

SELECT
    normalized_name,
    rating,
    review_count,
    price_tier,
    shop_type,
    address
FROM coffee_shops
WHERE review_count >= 300
  AND rating < 4.0
ORDER BY review_count DESC;


-- ============================================================
-- Query 9: Rating distribution
-- ============================================================
-- Groups coffee shops into rating bands to show how customer ratings
-- are distributed across the dataset.
--
-- Looking only at the overall average can hide important differences.
-- A distribution shows whether most shops are concentrated around
-- similar ratings or whether a meaningful number fall into lower or
-- higher performance ranges.
--
-- Business question:
-- How are coffee shops distributed across lower, average, and
-- high-performing rating categories?

SELECT
    rating_band,
    COUNT(*) AS shop_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_shops
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



-- ============================================================
-- Query 10: Most-reviewed coffee shops
-- ============================================================
-- Identifies the coffee shops with the highest number of customer
-- reviews.
--
-- Review count is used here as an indicator of customer engagement
-- and visibility rather than customer satisfaction. A highly reviewed
-- shop is not necessarily the highest rated, but it has generated a
-- substantial amount of customer interaction.
--
-- Business question:
-- Which coffee shops have attracted the greatest level of customer
-- engagement?

SELECT
    normalized_name,
    rating,
    review_count,
    price_tier,
    shop_type,
    address
FROM coffee_shops
ORDER BY review_count DESC
LIMIT 10;