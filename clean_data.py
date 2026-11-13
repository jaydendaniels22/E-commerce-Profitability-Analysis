"""
clean_data.py — E-commerce Profitability Analysis

Cleans and validates the three raw CSVs, writes cleaned copies to
data/clean/, and reconciles headline figures against the README.

Run:   python clean_data.py
Deps:  pandas
"""

from pathlib import Path
import pandas as pd

RAW = Path("data/raw")
CLEAN = Path("data/clean")
CLEAN.mkdir(parents=True, exist_ok=True)


def check(label, actual, expected, tol=0.02):
    """Assert a computed value matches the README within tolerance."""
    if abs(actual - expected) > tol:
        raise AssertionError(f"{label}: got {actual:,.2f}, expected {expected:,.2f}")
    print(f"  ok  {label} = {actual:,.2f}")


def clean_orders():
    print("orders.csv")
    df = pd.read_csv(RAW / "orders.csv")

    df["order_date"] = pd.to_datetime(df["order_date"], format="%Y/%m/%d")

    # Returned stays as 'Yes'/'No' text to match the SQL queries.
    # A derived boolean is added for convenience.
    df["returned"] = df["returned"].astype(str).str.strip().str.title()
    unexpected = set(df["returned"].unique()) - {"Yes", "No"}
    if unexpected:
        raise AssertionError(f"unexpected 'returned' values: {unexpected}")
    df["is_returned"] = df["returned"].eq("Yes")

    money = [
        "gross_revenue", "discount_amount", "shipping_cost", "product_cost",
        "platform_fee", "transaction_fee", "refund_amount", "net_revenue",
        "total_costs", "profit",
    ]
    for c in money:
        df[c] = pd.to_numeric(df[c], errors="raise")

    # Cost integrity: four cost components must equal total_costs.
    calc = df[["product_cost", "shipping_cost", "platform_fee", "transaction_fee"]].sum(axis=1)
    diff = (calc - df["total_costs"]).abs()
    if diff.max() > 0.02:
        row = df.loc[diff.idxmax(), "order_id"]
        raise AssertionError(f"cost integrity broken at {row} (max diff {diff.max():.2f})")
    print(f"  ok  cost integrity (max row diff {diff.max():.4f})")

    # Gross-to-net bridge: gross - discounts - refunds = net_revenue.
    bridge = df["gross_revenue"] - df["discount_amount"] - df["refund_amount"] - df["net_revenue"]
    if bridge.abs().sum() > 2:
        raise AssertionError(f"gross-to-net bridge fails (residual {bridge.sum():,.2f})")
    print(f"  ok  gross-to-net bridge (sum residual {bridge.sum():,.2f})")

    return df


def clean_products():
    print("products.csv")
    # utf-8-sig strips the BOM (ï»¿) that corrupts the first column name.
    df = pd.read_csv(RAW / "products.csv", encoding="utf-8-sig")
    if df.columns[0] != "product_id":
        raise AssertionError(f"expected 'product_id', got {df.columns[0]!r}")

    for c in ["unit_cost", "selling_price", "shipping_cost", "weight_lbs"]:
        df[c] = pd.to_numeric(df[c], errors="raise")

    df["unit_margin"] = df["selling_price"] - df["unit_cost"]
    return df


def clean_marketing():
    print("marketing_spend.csv")
    df = pd.read_csv(RAW / "marketing_spend.csv")

    # '24-Jan' -> 2024-01-01 so the month can join a date table.
    df["month_start"] = pd.to_datetime(df["month"], format="%y-%b")

    numeric = [
        "spend", "impressions", "clicks", "conversions",
        "revenue_attributed", "cpc", "cpa", "roas",
    ]
    for c in numeric:
        df[c] = pd.to_numeric(df[c], errors="raise")

    if df["id"].duplicated().any():
        raise AssertionError("duplicate ids in marketing_spend")
    return df


def reconcile(orders, products, spend):
    """Cross-check pandas against the numbers reported in the README."""
    print("headline reconciliation (vs README)")
    check("orders", len(orders), 2000, tol=0)
    check("gross revenue", orders["gross_revenue"].sum(), 277_969.13, tol=1)
    check("discounts", orders["discount_amount"].sum(), 21_068.31, tol=1)
    check("refunds", orders["refund_amount"].sum(), 20_581.00, tol=1)
    check("net revenue", orders["net_revenue"].sum(), 236_318.37, tol=1)
    check("profit", orders["profit"].sum(), 56_333.83, tol=1)
    check("attributed revenue", spend["revenue_attributed"].sum(), 8_146_615.20, tol=1)
    check("marketing spend", spend["spend"].sum(), 503_506.14, tol=1)

    margin = orders["profit"].sum() / orders["net_revenue"].sum()
    print(f"  ok  overall margin = {margin:.2%}")

    ratio = spend["revenue_attributed"].sum() / orders["net_revenue"].sum()
    print(f"  ok  attributed / net revenue = {ratio:.1f}x")

    print(f"  ok  return rate = {orders['is_returned'].mean():.2%}")


def main():
    orders = clean_orders()
    products = clean_products()
    spend = clean_marketing()
    reconcile(orders, products, spend)

    orders.to_csv(CLEAN / "orders_clean.csv", index=False)
    products.to_csv(CLEAN / "products_clean.csv", index=False)
    spend.to_csv(CLEAN / "marketing_spend_clean.csv", index=False)
    print(f"\nwrote 3 cleaned files to {CLEAN}/")


if __name__ == "__main__":
    main()
