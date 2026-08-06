# Coffee Shop Crawl

An end-to-end data analytics project that explores coffee shop trends in Washington, D.C. using Python, MySQL, SQL, and Tableau Public.

The goal of this project was to identify high-performing coffee shops, compare chain and independent businesses, analyze pricing patterns, and determine which shops offer the best overall value based on customer ratings, 
review volume, and price.

---

## Project Overview

Finding a good coffee shop is about more than just ratings. A shop with thousands of reviews may be more trustworthy than one with only a handful, while an expensive café isn't necessarily better than a budget-friendly 
one.

This project combines customer ratings, review counts, and pricing information to answer questions such as:

- Which coffee shops offer the best value for money?
- Do more expensive coffee shops receive better ratings?
- How do chain coffee shops compare to independent cafés?
- Which shops are popular but receive relatively poor customer ratings?
- Which lesser-known coffee shops deserve more attention?

---

## Dataset

The dataset contains coffee shop information collected from Yelp for businesses located in Washington, D.C.

Each record includes information such as:

- Business name
- Customer rating
- Review count
- Price tier
- Categories
- Address
- ZIP code
- Geographic coordinates

---

## Tools Used

- **Python** – Data cleaning and feature engineering
- **Pandas & NumPy** – Data transformation
- **MySQL** – Database design and SQL analysis
- **Tableau Public** – Interactive dashboard and data visualization

---

## Project Workflow

### 1. Data Collection

Coffee shop data was collected from Yelp and exported to CSV format.

### 2. Data Cleaning

The dataset was cleaned and standardized using Python.

Cleaning tasks included:

- Removing duplicate businesses
- Standardizing business names
- Handling missing values
- Normalizing text fields
- Creating derived features for analysis

### 3. Feature Engineering

Several new analytical fields were created, including:

- Rating Band
- Price Tier
- Shop Type (Chain vs. Independent)
- Hidden Gem indicator
- Custom Value Score

The **Value Score** combines:

- Customer rating
- Review credibility (using a logarithmic transformation of review count)
- Price level

This provides a balanced measure of overall value instead of relying on ratings alone.

### 4. Database Design

The cleaned dataset was imported into MySQL using a staging table before loading it into the final analytical table.

### 5. SQL Analysis

SQL queries were written to answer common business questions, including:

- Overall project KPIs
- Best value coffee shops
- Highest-rated reliable shops
- Hidden gems
- Price versus rating
- Coffee shop performance by ZIP code
- Chain versus independent shops
- Popular but underperforming businesses
- Rating distribution
- Most-reviewed coffee shops

### 6. Dashboard Development

The final Tableau dashboard summarizes the key findings through interactive visualizations and filters.

---

## Dashboard

**Interactive Dashboard**

*Add your Tableau Public link here*

**Dashboard Preview**

*Insert dashboard screenshot here*

---

## Key Insights

Some of the insights explored in this project include:

- Higher prices do not always correspond to higher customer ratings.
- Independent coffee shops often perform as well as—or better than—large chains.
- Some highly reviewed businesses receive surprisingly low customer ratings.
- Several lesser-known coffee shops provide excellent value despite having fewer reviews.

---

## Repository Structure

```text
coffee-shop-crawl/
│
├── data/
│   ├── coffee_shops_raw.csv
│   └── coffee_shops_clean.csv
│
├── scripts/
│   └── clean_coffee_data.py
│
├── sql/
│   ├── create_database.sql
│   └── coffee_shop_analysis.sql
│
├── tableau/
│   └── coffee_shop_dashboard.twbx
│
├── images/
│   └── dashboard.png
│
├── README.md
├── requirements.txt
└── .gitignore
```

---

## Future Improvements

Some possible extensions for this project include:

- Incorporating Google Places data for comparison
- Performing sentiment analysis on customer reviews
- Tracking changes in ratings over time
- Expanding the analysis to multiple cities

---

## Author

**Giselle Barretto**

Master of Science in Information Systems  
University of Maryland – Robert H. Smith School of Business
