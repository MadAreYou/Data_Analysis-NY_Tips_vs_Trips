# CA1 – NY Tips vs Trips

Data Analytics CA1 project (NYC Yellow Taxi 2024 × NOAA Weather 2024)  
Author: **Juraj Madzunkov**  
Sections: **C  Data Preparation** and **D  Advanced Analysis**

## Overview

This repository prepares and validates a joined dataset of NYC Yellow Taxi trips (2024) with hourly NYC weather (NOAA 2024). The processing is implemented in notebooks, with outputs published both locally (repo `data/`) and to an external X: drive for downstream analysis.

## Repository Layout

- /data – raw, interim, processed datasets  
- /notebooks – stepwise Jupyter notebooks  
- /docs – methodology, data dictionary, and decisions  

## Branches

- main → final deliverables  
- dev → active work  

## Environment

- Python 3.12 (recommended)
- Install dependencies:

```bash
pip install -r requirements.txt
```

## Data sources

- TLC Trip Data 2024 (Parquet): [TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) (CloudFront mirror used by notebook)
- NOAA LCD 2024 (CSV): [NOAA LCD Access 2024](https://www.ncei.noaa.gov/data/local-climatological-data/access/2024/)

## What’s completed so far

1. Downloaded TLC 2024 monthly Parquet files to X:.
2. Downloaded NOAA station CSVs (JFK, LGA, Central Park, Newark, Teterboro) and aggregated to city‑wide hourly metrics in NYC local time.
3. Validated NOAA aggregation (schema, coverage, recomputation parity, size efficiency).
4. Merged TLC trips with hourly weather on NYC local pickup hour (Step 6.3).
5. Added merge validations: parquet metadata parity, hour sampling, invariants, and an hour‑level report confirming numeric weather columns equal NOAA (on overlapping hours).

## Resulting datasets (ready for further work)

- NOAA aggregated hourly parquet
  - Local: `data/interim/noaa_hourly_citywide_2024.parquet`
  - X: `X:\data\interim\noaa_hourly_citywide_2024.parquet`

- Final merged trips × weather
  - Local (Parquet): `data/processed/nyc_2024_trips_weather.parquet`
  - Local (Sample CSV): `data/processed/nyc_2024_trips_weather_sample.csv`
  - X (Parquet): `X:\data\processed\nyc_2024_trips_weather.parquet`
  - X (Sample CSV): `X:\data\processed\nyc_2024_trips_weather_sample.csv`

## How to reproduce key steps

- Open `notebooks/01_ingest_explore.ipynb` and run the sections in order:
  - TLC 2024 data collection → downloads monthly files to X:
  - NOAA Weather Data → downloads station CSVs and writes aggregated city‑hour parquet (local → copy to X:)
  - Data validation → validates the NOAA parquet
  - Merge & Export → merges TLC with hourly weather, writes outputs (local → copy to X:)
  - Validation (end) → verifies the merged dataset and produces an hour‑level comparison report vs NOAA

Notes:

- All writes are performed locally first, then copied to X: with retries for network stability.
- The join key is NYC local hour (`pickup_hour_local`).

## Validation summary (high level)

- TLC × NOAA merged rows: 41,169,720
- Numeric weather columns match NOAA per hour across intersecting hours (share_equal = 1.0; max abs diffs at floating‑point noise).
- Invariants hold: rows without matching weather hour have all weather columns null; matched rows have weather populated where available.

## Next steps

- Begin downstream analysis in notebooks under Section D (Advanced Analysis) using the merged parquet on X:.
