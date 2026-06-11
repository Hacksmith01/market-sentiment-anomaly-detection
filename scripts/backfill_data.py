import os

from dotenv import load_dotenv
import psycopg2
import yfinance as yf


load_dotenv()

TICKERS = [
    "RELIANCE.NS",
    "TCS.NS",
    "INFY.NS",
    "HDFCBANK.NS",
    "WIPRO.NS",
    "BAJFINANCE.NS",
    "ADANIENT.NS",
    "ITC.NS",
    "SBIN.NS",
    "MARUTI.NS",
]


def _value(row, column):
    value = row[column]
    if hasattr(value, "iloc"):
        value = value.iloc[0]
    return value


def backfill():
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError("DATABASE_URL is not set. Check your .env file.")

    conn = psycopg2.connect(database_url)
    cur = conn.cursor()

    try:
        for ticker in TICKERS:
            print(f"Backfilling {ticker}...")
            try:
                data = yf.download(
                    ticker,
                    period="6mo",
                    interval="1d",
                    progress=False,
                    auto_adjust=True,
                )

                count = 0
                for idx, row in data.iterrows():
                    cur.execute(
                        """
                        INSERT INTO price_data
                            (ticker, timestamp, open, high, low, close, volume)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (ticker, timestamp) DO NOTHING
                        """,
                        (
                            ticker,
                            idx.to_pydatetime(),
                            float(_value(row, "Open")),
                            float(_value(row, "High")),
                            float(_value(row, "Low")),
                            float(_value(row, "Close")),
                            int(_value(row, "Volume")),
                        ),
                    )
                    count += 1

                conn.commit()
                print(f"  [OK] {ticker}: {count} records backfilled")

            except Exception as exc:
                print(f"  [ERROR] {ticker}: {exc}")
                conn.rollback()
    finally:
        cur.close()
        conn.close()

    print("Backfill complete.")


if __name__ == "__main__":
    backfill()
