from apscheduler.schedulers.blocking import BlockingScheduler
from dotenv import load_dotenv

from ingestion.price_fetcher import fetch_latest_prices


load_dotenv()

scheduler = BlockingScheduler(timezone="Asia/Kolkata")

scheduler.add_job(
    fetch_latest_prices,
    "cron",
    day_of_week="mon-fri",
    hour="9-15",
    minute="*/15",
    id="price_fetcher",
)


if __name__ == "__main__":
    print("Scheduler starting...")
    print("Price fetcher: every 15 min, Mon-Fri 9:00-15:00 IST")
    scheduler.start()
