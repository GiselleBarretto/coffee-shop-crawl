import re
import unicodedata
from pathlib import Path

import numpy as np
import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent.parent
INPUT_FILE = PROJECT_ROOT / "data" / "coffee_shops_raw.csv"
OUTPUT_FILE = PROJECT_ROOT / "data" / "coffee_shops_clean.csv"


# Add known chains here as needed.
KNOWN_CHAINS = {
    "starbucks",
    "dunkin",
    "blue bottle coffee",
    "peets coffee",
    "tatte bakery and cafe",
    "la colombe",
    "compass coffee",
    "pret a manger",
    "joe and the juice",
    "gregorys coffee",
    "maman",
    "petite maman",
    "slipstream",
    "bluestone lane",
    "blank street coffee",
    "blank street",
    "colada shop",
    "for five coffee roasters",
    "dolcezza",
    "peregrine espresso",
    "call your mother deli",
    "tous les jours",
    "emissary",
    "south block",
    "commonwealth joe",
    "filter coffeehouse",
    "spot of tea",
    "capital one cafe",
    "union kitchen",
    "fresh baguette",
    "swings coffee",
    "swing coffee roasters",
    "unido",
    "pluma",
    "simona cafe",
    "the coffee bar",
    "dua dc coffee",
    "lavazza",
    "corner bakery cafe",
    "roasting plant coffee",
    "bad ass coffee of hawaii",
    "pitango gelato and coffee",
    "land of a thousand hills coffee",
    "toastique",
    "qargo coffee",
    "cotti coffee",
    "the salty donut",
    "crumbs and whiskers",
    "vigilante coffee",
}


def normalize_business_name(name: str) -> str:
    """
    Standardize a business name so that chain matching is more reliable.

    Examples:
        "Tatte Bakery & Cafe | Dupont Circle"
        becomes
        "tatte bakery and cafe dupont circle"

        "Büna Coffeehouse"
        becomes
        "buna coffeehouse"
    """
    if pd.isna(name):
        return ""

    normalized_name = str(name).strip().casefold()

    # Remove accents:
    # Café -> Cafe
    # Büna -> Buna
    normalized_name = unicodedata.normalize(
        "NFKD",
        normalized_name,
    )

    normalized_name = "".join(
        character
        for character in normalized_name
        if not unicodedata.combining(character)
    )

    # Standardize "&" so that "&" and "and" match.
    normalized_name = normalized_name.replace("&", " and ")

    # Replace common separators and punctuation with spaces.
    normalized_name = re.sub(
        r"[|/\\_–—-]+",
        " ",
        normalized_name,
    )

    normalized_name = re.sub(
        r"[^a-z0-9\s]",
        "",
        normalized_name,
    )

    # Replace multiple spaces with one space.
    normalized_name = re.sub(
        r"\s+",
        " ",
        normalized_name,
    ).strip()

    return normalized_name


def classify_chain(name: str) -> str:
    """Classify businesses using a normalized known-chain list."""
    if pd.isna(name):
        return "Unknown"

    normalized_name = normalize_business_name(name)

    for chain in KNOWN_CHAINS:
        normalized_chain = normalize_business_name(chain)

        if normalized_chain in normalized_name:
            return "Chain"

    return "Independent / Local"


def clean_data(dataframe: pd.DataFrame) -> pd.DataFrame:
    """Clean fields and create analytical features."""
    df = dataframe.copy()

    # -----------------------------------------------------
    # Remove exact duplicate business IDs
    # -----------------------------------------------------

    df = df.drop_duplicates(
        subset=["business_id"],
        keep="first",
    )

    # -----------------------------------------------------
    # Remove closed shops
    # -----------------------------------------------------

    df["is_closed"] = (
        df["is_closed"]
        .astype(str)
        .str.strip()
        .str.lower()
        .map({
            "true": True,
            "false": False,
        })
    )

    df = df[df["is_closed"] != True].copy()

    # -----------------------------------------------------
    # Clean text fields
    # -----------------------------------------------------

    text_columns = [
        "name",
        "categories",
        "address",
        "address1",
        "city",
        "state",
        "zip_code",
    ]

    for column in text_columns:
        if column in df.columns:
            df[column] = (
                df[column]
                .astype("string")
                .str.strip()
            )

    
    # Create a normalized version of the business name
    # for matching and analysis.
    df["normalized_name"] = df["name"].apply(
        normalize_business_name
    )

    # -----------------------------------------------------
    # Correct numerical data types
    # -----------------------------------------------------

    numeric_columns = [
        "rating",
        "review_count",
        "latitude",
        "longitude",
    ]

    for column in numeric_columns:
        df[column] = pd.to_numeric(
            df[column],
            errors="coerce",
        )

    df["review_count"] = (
        df["review_count"]
        .fillna(0)
        .astype(int)
    )

    # -----------------------------------------------------
    # Clean price
    # -----------------------------------------------------

    df["price"] = df["price"].fillna("Unknown")

    valid_price_values = {
        "$",
        "$$",
        "$$$",
        "$$$$",
        "Unknown",
    }

    df.loc[
        ~df["price"].isin(valid_price_values),
        "price",
    ] = "Unknown"

    price_mapping = {
        "$": 1,
        "$$": 2,
        "$$$": 3,
        "$$$$": 4,
    }

    df["price_level"] = df["price"].map(
        price_mapping
    )

    df["price_level"] = df["price_level"].astype("Int64")

    # -----------------------------------------------------
    # Create price labels
    # -----------------------------------------------------

    price_label_mapping = {
        "$": "Budget",
        "$$": "Moderate",
        "$$$": "Expensive",
        "$$$$": "Luxury",
        "Unknown": "Unknown",
    }

    df["price_tier"] = df["price"].map(
        price_label_mapping
    )

    # -----------------------------------------------------
    # Create shop classification
    # -----------------------------------------------------

    df["shop_type"] = df["name"].apply(
        classify_chain
    )

    # -----------------------------------------------------
    # Create popularity bands
    # -----------------------------------------------------

    df["popularity_band"] = pd.cut(
        df["review_count"],
        bins=[
            -1,
            49,
            199,
            499,
            float("inf"),
        ],
        labels=[
            "Low: under 50 reviews",
            "Medium: 50-199 reviews",
            "High: 200-499 reviews",
            "Very high: 500+ reviews",
        ],
    )

    # -----------------------------------------------------
    # Create rating bands
    # -----------------------------------------------------

    df["rating_band"] = pd.cut(
        df["rating"],
        bins=[
            0,
            3.49,
            3.99,
            4.49,
            5.0,
        ],
        labels=[
            "Below 3.5",
            "3.5-3.9",
            "4.0-4.4",
            "4.5-5.0",
        ],
        include_lowest=True,
    )

    # -----------------------------------------------------
    # Create a review-confidence measure
    # -----------------------------------------------------
    # Log transformation prevents shops with thousands of
    # reviews from completely dominating the calculation.

    df["review_strength"] = np.log1p(
        df["review_count"]
    )

    max_strength = df["review_strength"].max()

    if pd.notna(max_strength) and max_strength > 0:
        df["review_strength_normalized"] = (
            df["review_strength"] / max_strength
        )
    else:
        df["review_strength_normalized"] = 0

    # -----------------------------------------------------
    # Create value score
    # -----------------------------------------------------
    # Only calculate value when price is known.
    #
    # Rating component: up to 80 points
    # Review-confidence component: up to 20 points
    # Price penalty: more expensive shops receive a deduction

    df["value_score"] = np.where(
        df["price_level"].notna(),
        (
            (df["rating"] / 5.0) * 80
            + df["review_strength_normalized"] * 20
            - (df["price_level"] - 1) * 8
        ),
        np.nan,
    )

    df["value_score"] = df["value_score"].round(2)

    # -----------------------------------------------------
    # Create hidden-gem flag
    # -----------------------------------------------------
    # A hidden gem is strongly rated but has not yet
    # accumulated a very high number of reviews.

    df["hidden_gem"] = np.where(
        (df["rating"] >= 4.5)
        & df["review_count"].between(20, 150),
        "Yes",
        "No",
    )

    # -----------------------------------------------------
    # Create reliable-rating flag
    # -----------------------------------------------------

    df["rating_reliability"] = np.where(
        df["review_count"] >= 50,
        "50+ reviews",
        "Under 50 reviews",
    )

    # -----------------------------------------------------
    # Keep valid map coordinates
    # -----------------------------------------------------

    df = df[
        df["latitude"].notna()
        & df["longitude"].notna()
    ].copy()

    # -----------------------------------------------------
    # Reorder columns
    # -----------------------------------------------------

    final_columns = [
        "business_id",
        "name",
        "normalized_name",
        "rating",
        "review_count",
        "rating_band",
        "rating_reliability",
        "price",
        "price_level",
        "price_tier",
        "value_score",
        "hidden_gem",
        "shop_type",
        "popularity_band",
        "categories",
        "address",
        "address1",
        "city",
        "state",
        "zip_code",
        "latitude",
        "longitude",
        "phone",
        "yelp_url",
        "image_url",
    ]

    return df[final_columns]


def main() -> None:

    print(
    "DIRECT FUNCTION TEST:",
    normalize_business_name(
        "Tatte Bakery & Cafe | 14th St"
    ),
)
    
    df = pd.read_csv(
        INPUT_FILE,
        encoding="utf-8-sig",
        dtype={
            "business_id": "string",
            "zip_code": "string",
        },
    )

    clean_df = clean_data(df)

    #print(clean_df.dtypes)
    print("\nBEFORE SAVING:")
    print(
        clean_df.loc[
            clean_df["name"].str.contains(
                "Tatte|Lot 38",
                case=False,
                na=False,
            ),
            ["name", "normalized_name"],
        ].to_string(index=False)
    )

    clean_df.to_csv(
        OUTPUT_FILE,
        index=False,
        encoding="utf-8-sig",
        na_rep="",
    )

    print(f"Raw rows: {len(df)}")
    print(f"Clean rows: {len(clean_df)}")

    print(
        "Duplicate business IDs: "
        f"{clean_df['business_id'].duplicated().sum()}"
    )

    print(
        "Missing ratings: "
        f"{clean_df['rating'].isna().sum()}"
    )

    print(
        "Missing price classifications: "
        f"{(clean_df['price'] == 'Unknown').sum()}"
    )

    print(f"Clean file saved to: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()