DROP DATABASE IF EXISTS coffee_shop_crawl;

CREATE DATABASE coffee_shop_crawl;

USE coffee_shop_crawl;

DROP TABLE IF EXISTS coffee_shops_staging;
DROP TABLE IF EXISTS coffee_shops;

CREATE TABLE coffee_shops (
    business_id VARCHAR(100) PRIMARY KEY,
    cafe_name VARCHAR(255) NOT NULL,
    normalized_name varchar(255) NOT NULL,
    rating DECIMAL(2,1),
    review_count INT,
    rating_band VARCHAR(30),
    rating_reliability VARCHAR(30),
    price VARCHAR(20),
    price_level TINYINT,
    price_tier VARCHAR(20),
    value_score DECIMAL(6,2),
    hidden_gem VARCHAR(3),
    shop_type VARCHAR(30),
    popularity_band VARCHAR(50),
    categories TEXT,
    address VARCHAR(500),
    address1 VARCHAR(255),
    city VARCHAR(100),
    state CHAR(2),
    zip_code VARCHAR(10),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    phone VARCHAR(30),
    yelp_url TEXT,
    image_url TEXT
);

CREATE TABLE coffee_shops_staging (
    business_id TEXT,
    cafe_name TEXT,
    normalized_name TEXT,
    rating TEXT,
    review_count TEXT,
    rating_band TEXT,
    rating_reliability TEXT,
    price TEXT,
    price_level TEXT,
    price_tier TEXT,
    value_score TEXT,
    hidden_gem TEXT,
    shop_type TEXT,
    popularity_band TEXT,
    categories TEXT,
    address TEXT,
    address1 TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    latitude TEXT,
    longitude TEXT,
    phone TEXT,
    yelp_url TEXT,
    image_url TEXT
);

SELECT * FROM coffee_shops_staging;

SELECT COUNT(*) AS total FROM coffee_shops_staging;

INSERT INTO coffee_shops (
    business_id,
    cafe_name,
    normalized_name,
    rating,
    review_count,
    rating_band,
    rating_reliability,
    price,
    price_level,
    price_tier,
    value_score,
    hidden_gem,
    shop_type,
    popularity_band,
    categories,
    address,
    address1,
    city,
    state,
    zip_code,
    latitude,
    longitude,
    phone,
    yelp_url,
    image_url
)
SELECT
    NULLIF(TRIM(business_id), ''),
    NULLIF(TRIM(cafe_name), ''),
    NULLIF(TRIM(normalized_name), ''),
    CAST(NULLIF(TRIM(rating), '') AS DECIMAL(2,1)),
    CAST(NULLIF(TRIM(review_count), '') AS UNSIGNED),
    NULLIF(TRIM(rating_band), ''),
    NULLIF(TRIM(rating_reliability), ''),
    NULLIF(TRIM(price), ''),
    CAST(NULLIF(TRIM(price_level), '') AS UNSIGNED),
    NULLIF(TRIM(price_tier), ''),
    CAST(NULLIF(TRIM(value_score), '') AS DECIMAL(6,2)),
    NULLIF(TRIM(hidden_gem), ''),
    NULLIF(TRIM(shop_type), ''),
    NULLIF(TRIM(popularity_band), ''),
    NULLIF(TRIM(categories), ''),
    NULLIF(TRIM(address), ''),
    NULLIF(TRIM(address1), ''),
    NULLIF(TRIM(city), ''),
    NULLIF(TRIM(state), ''),
    NULLIF(TRIM(zip_code), ''),
    CAST(NULLIF(TRIM(latitude), '') AS DECIMAL(10,7)),
    CAST(NULLIF(TRIM(longitude), '') AS DECIMAL(10,7)),
    NULLIF(TRIM(phone), ''),
    NULLIF(TRIM(yelp_url), ''),
    NULLIF(TRIM(image_url), '')
FROM coffee_shops_staging;

#Remove BOM signature from the cafe name column
-- SET SQL_SAFE_UPDATES = 0;

-- UPDATE coffee_shops
-- SET cafe_name = REPLACE(cafe_name, UNHEX('EFBBBF'), '')
-- WHERE cafe_name LIKE CONCAT(UNHEX('EFBBBF'), '%');

-- SET SQL_SAFE_UPDATES = 1;

ALTER TABLE coffee_shops
DROP COLUMN cafe_name;

SELECT * FROM coffee_shops;

SELECT COUNT(*) AS total FROM coffee_shops;