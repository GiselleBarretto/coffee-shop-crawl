from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent.parent
FILE_PATH = PROJECT_ROOT / "data" / "coffee_shops_clean.csv"

df = pd.read_csv(
    FILE_PATH,
    encoding="utf-8-sig",
    dtype={
        "business_id": "string",
        "zip_code": "string",
    },
)

print("File being checked:")
print(FILE_PATH.resolve())

print("\nColumns:")
print(df.columns.tolist())

print("\nSelected rows:")
print(
    df.loc[
        df["name"].str.contains(
            "Tatte|Lot 38|Coffee Shop",
            case=False,
            na=False,
        ),
        ["name", "normalized_name", "rating", "review_count"],
    ].to_string(index=False)
)

print("SCRIPT RUNNING FROM:", Path(__file__).resolve())