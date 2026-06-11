from datetime import datetime
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


def get_db_connection():
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError("DATABASE_URL is not set. Check your .env file.")
    return psycopg2.connect(database_url)


def _value(row, column):
    value = row[column]
    if hasattr(value, "iloc"):
        value = value.iloc[0]
    return value


def fetch_latest_prices():
    print(f"[{datetime.now()}] Fetching prices for {len(TICKERS)} stocks...")
    conn = get_db_connection()
    cur = conn.cursor()

    try:
        for ticker in TICKERS:
            try:
                data = yf.download(
                    ticker,
                    period="1d",
                    interval="15m",
                    progress=False,
                    auto_adjust=True,
                )
                if data.empty:
                    print(f"  No data for {ticker}")
                    continue

                for idx, row in data.iterrows():
                    cur.execute(
                        """
                        INSERT INTO price_data
                            (ticker, timestamp, open, high, low, close, volume)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (ticker, timestamp) DO UPDATE SET
                            open = EXCLUDED.open,
                            high = EXCLUDED.high,
                            low = EXCLUDED.low,
                            close = EXCLUDED.close,
                            volume = EXCLUDED.volume
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

                print(f"  [OK] {ticker}: {len(data)} records stored")

            except Exception as exc:
                print(f"  [ERROR] Error fetching {ticker}: {exc}")

        conn.commit()
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    fetch_latest_prices()
