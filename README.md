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

### Authoritative handoff (preprocessed)

- Local (Parquet): `data/processed/nyc_2024_trips_weather_preprocessed.parquet`
- X (Parquet): `X:\data\processed\nyc_2024_trips_weather_preprocessed.parquet`

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

## Preprocessing and QC status (Notebooks 02 and 03)

### Notebook 02 — Clean & Normalize (source of truth)

- Missing values
  - Numeric-only median imputation; non-numeric handled later (e.g., `weather_code` → `"UNKNOWN"`).
- Outliers
  - IQR preview followed by refined caps at p99.9 with pragmatic ceilings; monetary fields floored at 0.
- Feature engineering
  - `tip_percent_raw` (0–100, clipped), `tip_percent_z` (standardized), `fare_per_km`.
  - Time features when timestamps present: `duration_min`, `pickup_hour`, `dow` (0=Mon), `month`, `season`.
- Encoding & scaling
  - `payment_type` one-hot with `drop_first=True`.
  - Standardize selected continuous features for modeling; fee/surcharge components may remain in original units for interpretability.
- Export integrity
  - Export QC Gate (idempotent fills + strict numeric NA check) and an RQ-fields QC check.
  - Final save locally, copy to X:, then post-copy verification (re-open X: parquet and re-check completeness).

Outcome: produces the authoritative preprocessed parquet consumed by downstream notebooks.

### Notebook 03 — QC & validation (read-only)

- Loads from X: authoritative parquet and performs:
  - Null audit (expected: none), summary stats, correlation heatmap, pairplot.
  - Tip distribution plots use `tip_percent_raw` when available; fallback to z-score with adjusted labels.
  - RQ readiness check (column presence only) → PASS for RQ1, RQ2, RQ3.
- Notes
  - Pearson correlations are scale-invariant; standardization doesn’t change coefficients (it helps downstream methods).

Status: dataset is complete and validated; ready for analysis in Notebook 04.

### Run order for preprocessing/QC

1. `notebooks/02_clean_normalize.ipynb` — Run top→bottom through: missing-value handling; outlier caps; feature engineering; “Minimal derived features for Research Questions” (adds tip_percent_raw, temporal fields); Export QC Gate(s); Final Save → Copy to X: → Post-copy verification.

2. `notebooks/03_qc_validation.ipynb` — Load from X:, run QC steps 2–6 and the final “RQ readiness check”. Expected: tip plots on raw % (0–60% focus) and overall RQ readiness = READY.

## Validation summary (high level)

- TLC × NOAA merged rows: 41,169,720
- Numeric weather columns match NOAA per hour across intersecting hours (share_equal = 1.0; max abs diffs at floating‑point noise).
- Invariants hold: rows without matching weather hour have all weather columns null; matched rows have weather populated where available.

## Next steps

- Begin downstream analysis in Notebook 04 (EDA & export) to answer the research questions:
  - RQ1: distance/duration and spatial patterns vs. tip_amount and tip_percent_raw (binning + heatmaps).
  - RQ2: temporal effects (hour × day-of-week heatmap; monthly/seasonal trends).
  - RQ3: fare components’ association with tip_amount, controlled within distance/duration bins.

Changelog (dev): latest commit updates Notebooks 02/03 to add RQ features, export QC, corrected plots/markdown, and README status.
