import os
import time
from pathlib import Path

import pandas as pd
import requests
from dotenv import load_dotenv


# ---------------------------------------------------------
# File paths
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_FILE = PROJECT_ROOT / "data" / "coffee_shops_raw.csv"
ENV_FILE = PROJECT_ROOT / ".env"


# ---------------------------------------------------------
# Load API key
# ---------------------------------------------------------

load_dotenv(ENV_FILE)

API_KEY = os.getenv("YELP_API_KEY")

if not API_KEY:
    raise ValueError(
        "YELP_API_KEY was not found. "
        "Add it to the .env file in the project root."
    )


# ---------------------------------------------------------
# Yelp request settings
# ---------------------------------------------------------

API_URL = "https://api.yelp.com/v3/businesses/search"

HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Accept": "application/json",
}

LOCATION = "Washington, DC"
SEARCH_TERM = "coffee"
CATEGORY = "coffee"
RESULTS_PER_REQUEST = 50

# Yelp's search endpoint has a finite result limit.
MAX_RESULTS = 200


def extract_category_titles(categories: list[dict]) -> str:
    """Convert Yelp category objects into one readable string."""
    if not categories:
        return ""

    return ", ".join(
        category.get("title", "")
        for category in categories
        if category.get("title")
    )


def extract_address(location: dict) -> str:
    """Combine Yelp display-address components."""
    if not location:
        return ""

    display_address = location.get("display_address", [])
    return ", ".join(display_address)


def fetch_coffee_shops() -> list[dict]:
    """Fetch coffee-shop results from Yelp using pagination."""
    all_businesses = []

    for offset in range(0, MAX_RESULTS, RESULTS_PER_REQUEST):
        params = {
            "term": SEARCH_TERM,
            "categories": CATEGORY,
            "location": LOCATION,
            "limit": RESULTS_PER_REQUEST,
            "offset": offset,
            "sort_by": "best_match",
        }

        print(
            f"Requesting results {offset + 1} "
            f"through {offset + RESULTS_PER_REQUEST}..."
        )

        response = requests.get(
            API_URL,
            headers=HEADERS,
            params=params,
            timeout=30,
        )

        try:
            response.raise_for_status()
        except requests.HTTPError as error:
            print("Yelp API request failed.")
            print("Status code:", response.status_code)
            print("Response:", response.text)
            raise error

        payload = response.json()
        businesses = payload.get("businesses", [])

        if not businesses:
            print("No additional businesses returned.")
            break

        all_businesses.extend(businesses)

        # Stop when fewer than the requested number are returned.
        if len(businesses) < RESULTS_PER_REQUEST:
            break

        # Small pause to avoid sending requests too rapidly.
        time.sleep(0.5)

    return all_businesses


def transform_businesses(businesses: list[dict]) -> pd.DataFrame:
    """Convert nested Yelp JSON into a flat table."""
    records = []

    for business in businesses:
        location = business.get("location", {})
        coordinates = business.get("coordinates", {})

        records.append(
            {
                "business_id": business.get("id"),
                "name": business.get("name"),
                "rating": business.get("rating"),
                "review_count": business.get("review_count"),
                "price": business.get("price"),
                "is_closed": business.get("is_closed"),
                "categories": extract_category_titles(
                    business.get("categories", [])
                ),
                "address": extract_address(location),
                "address1": location.get("address1"),
                "city": location.get("city"),
                "state": location.get("state"),
                "zip_code": location.get("zip_code"),
                "latitude": coordinates.get("latitude"),
                "longitude": coordinates.get("longitude"),
                "phone": business.get("display_phone"),
                "yelp_url": business.get("url"),
                "image_url": business.get("image_url"),
            }
        )

    return pd.DataFrame(records)


def main() -> None:
    businesses = fetch_coffee_shops()
    dataframe = transform_businesses(businesses)

    # Prevent Excel from interpreting business IDs as formulas
    dataframe["business_id"] = "'" + dataframe["business_id"].astype(str)
    
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    dataframe.to_csv(OUTPUT_FILE, index=False,encoding="utf-8-sig")

    print()
    print(f"Retrieved {len(dataframe)} records.")
    print(f"Raw file saved to: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()