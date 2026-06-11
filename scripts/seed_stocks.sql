INSERT INTO stocks (ticker, name, sector) VALUES
    ('RELIANCE.NS',   'Reliance Industries',    'Energy'),
    ('TCS.NS',        'Tata Consultancy Svcs',  'IT Services'),
    ('INFY.NS',       'Infosys',                'IT Services'),
    ('HDFCBANK.NS',   'HDFC Bank',              'Banking'),
    ('WIPRO.NS',      'Wipro',                  'IT Services'),
    ('BAJFINANCE.NS', 'Bajaj Finance',          'NBFC'),
    ('ADANIENT.NS',   'Adani Enterprises',      'Infrastructure'),
    ('ITC.NS',        'ITC Limited',            'FMCG'),
    ('SBIN.NS',       'State Bank of India',    'Banking'),
    ('MARUTI.NS',     'Maruti Suzuki',          'Automobile')
ON CONFLICT DO NOTHING;
