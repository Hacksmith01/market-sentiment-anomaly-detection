CREATE TABLE IF NOT EXISTS stocks (
    ticker          VARCHAR(20) PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    sector          VARCHAR(50),
    exchange        VARCHAR(10) DEFAULT 'NSE',
    added_at        TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS price_data (
    id              BIGSERIAL PRIMARY KEY,
    ticker          VARCHAR(20) REFERENCES stocks(ticker),
    timestamp       TIMESTAMP NOT NULL,
    open            DECIMAL(12,4),
    high            DECIMAL(12,4),
    low             DECIMAL(12,4),
    close           DECIMAL(12,4),
    volume          BIGINT,
    UNIQUE(ticker, timestamp)
);

CREATE INDEX IF NOT EXISTS idx_price_ticker_time
    ON price_data(ticker, timestamp DESC);

CREATE TABLE IF NOT EXISTS news_items (
    id              BIGSERIAL PRIMARY KEY,
    headline        TEXT NOT NULL,
    source          VARCHAR(100),
    url             TEXT,
    published_at    TIMESTAMP,
    fetched_at      TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_news_published
    ON news_items(published_at DESC);

CREATE TABLE IF NOT EXISTS news_ticker_map (
    news_id         BIGINT REFERENCES news_items(id),
    ticker          VARCHAR(20) REFERENCES stocks(ticker),
    match_type      VARCHAR(20) DEFAULT 'keyword',
    PRIMARY KEY (news_id, ticker)
);

CREATE TABLE IF NOT EXISTS sentiment_scores (
    id              BIGSERIAL PRIMARY KEY,
    news_id         BIGINT REFERENCES news_items(id),
    ticker          VARCHAR(20) REFERENCES stocks(ticker),
    label           VARCHAR(10) NOT NULL,
    score           DECIMAL(6,4) NOT NULL,
    signed_score    DECIMAL(6,4),
    model_version   VARCHAR(50) DEFAULT 'ProsusAI/finbert',
    scored_at       TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sentiment_ticker_time
    ON sentiment_scores(ticker, scored_at DESC);

CREATE TABLE IF NOT EXISTS anomaly_events (
    id              BIGSERIAL PRIMARY KEY,
    ticker          VARCHAR(20) REFERENCES stocks(ticker),
    detected_at     TIMESTAMP NOT NULL,
    anomaly_type    VARCHAR(20) NOT NULL,
    price_zscore    DECIMAL(8,4),
    volume_zscore   DECIMAL(8,4),
    close_price     DECIMAL(12,4),
    volume          BIGINT,
    triggered_alert BOOLEAN DEFAULT FALSE,
    alert_sent_at   TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_anomaly_ticker_time
    ON anomaly_events(ticker, detected_at DESC);

CREATE TABLE IF NOT EXISTS correlation_results (
    id               BIGSERIAL PRIMARY KEY,
    ticker           VARCHAR(20) REFERENCES stocks(ticker),
    computed_at      TIMESTAMP DEFAULT NOW(),
    lag_periods      INT NOT NULL,
    correlation      DECIMAL(8,6),
    p_value          DECIMAL(10,8),
    sample_size      INT,
    date_range_start TIMESTAMP,
    date_range_end   TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alert_history (
    id              BIGSERIAL PRIMARY KEY,
    ticker          VARCHAR(20) REFERENCES stocks(ticker),
    anomaly_id      BIGINT REFERENCES anomaly_events(id),
    alert_type      VARCHAR(30),
    message         TEXT,
    sent_at         TIMESTAMP DEFAULT NOW(),
    success         BOOLEAN DEFAULT TRUE
);
