# CA1 – NY Tips vs Trips

Data Analytics CA1 project (NYC Yellow Taxi 2024 × NOAA Weather 2024)  
Author: **Juraj Madzunkov**  
Sections: **C  Data Preparation** and **D  Advanced Analysis**

## Overview

This repository delivers an end‑to‑end analysis of tipping behavior using a joined dataset of NYC Yellow Taxi trips (2024) and hourly NYC weather (NOAA 2024). The workflow is implemented in four notebooks that: ingest and join data, clean/normalize, run QC, and perform EDA aligned to the three research questions (RQ1–RQ3). The final notebook saves report‑ready figures, tables, and markdown blocks.

## Repository Layout

- `data/` – raw, interim, processed datasets  
- `notebooks/` – stepwise Jupyter notebooks (01–04)  
- `docs/` – methodology, data dictionary, decisions, figures/tables, report blocks  
  - `docs/figures/` – PNGs exported from notebook 04  
  - `docs/tables/` – CSV tables exported from notebook 04  
  - `docs/report_blocks/` – copy‑paste markdown summaries (RQ1–RQ3, executive)

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

## What’s completed

1. Downloaded TLC 2024 monthly Parquet files to X:.
2. Downloaded NOAA station CSVs (JFK, LGA, Central Park, Newark, Teterboro) and aggregated to city‑wide hourly metrics in NYC local time.
3. Validated NOAA aggregation (schema, coverage, parity, and size efficiency).
4. Merged TLC trips with hourly weather on NYC local pickup hour with strict validations.
5. Cleaned/normalized the merged dataset; added derived features for analysis (tip_percent_raw, duration_min, temporal fields, etc.).
6. QC’d the authoritative parquet (null audit, stats, correlations, RQ readiness = PASS).
7. EDA aligned to RQ1–RQ3; exported figures, tables, and report‑ready markdown blocks.

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

## How to reproduce (01 → 04)

- 01 — `notebooks/01_ingest_explore.ipynb`: Download TLC 2024 (Parquet) and NOAA station CSVs; aggregate NOAA to NYC hourly (local → copy to X:); validate NOAA parquet and join keys.
- 02 — `notebooks/02_clean_normalize.ipynb`: Handle missing values and outliers; engineer features (tip% and time); run export QC gates; save authoritative preprocessed parquet (local + X:) with post‑copy verification.
- 03 — `notebooks/03_qc_validation.ipynb`: Read authoritative parquet from X:, run QC and confirm RQ readiness (PASS expected).
- 04 — `notebooks/04_eda_export.ipynb`: Answer RQ1–RQ3 with aggregation‑first analysis; export figures/tables and report markdown blocks.

Notes

- Writes happen locally first, then copy to X: with retries.  
- Key join is NYC local hour (`pickup_hour_local`).

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

## Analysis (Notebook 04) — EDA & Export

Notebook: `notebooks/04_eda_export.ipynb`

Purpose: answer RQ1–RQ3 using aggregation-first methods, save figures/tables, and generate report-ready summaries.

What it does

- Loads the authoritative preprocessed parquet (from X: with local fallback).
- RQ1: distance × duration binning (medians + counts), heatmap; spatial top/bottom pickup/drop-off areas.
- RQ2: temporal patterns (by hour, day-of-week, month/season), hour×DOW heatmap; selected weather bins.
- RQ3: within-bin (distance×duration) comparisons for fee flags (tolls, congestion, airport) and their median deltas.
- Each RQ shows styled tables in-notebook and a concise narrative answer directly beneath the technical outputs.

Artifacts

- Figures: `docs/figures/*.png` (e.g., `rq1_heatmap_tip_percent.png`, `rq2_hour_tip_pct.png`, `rq3_withinbin_deltas.png`).
- Tables: `docs/tables/*.csv` for key aggregations per RQ.
- Report blocks (auto-generated markdown): `docs/report_blocks/`
  - `rq1_summary.md`, `rq2_summary.md`, `rq3_summary.md`, and `executive_summary.md`.

How to run

1. Ensure dependencies are installed (see Environment).
2. Open `notebooks/04_eda_export.ipynb` and run all cells top→bottom.
3. On completion, review figures/tables in `docs/figures` and `docs/tables` and the markdown summaries in `docs/report_blocks` for copy-paste into reports.

Notes

- Medians are used for robustness; counts (n) are included to gauge reliability.
- Results are observational; interpret deltas as associations, not causal effects.

## Validation summary (high level)

- TLC × NOAA merged rows: 41,169,720
- Numeric weather columns match NOAA per hour across intersecting hours (share_equal = 1.0; max abs diffs at floating‑point noise).
- Invariants hold: rows without matching weather hour have all weather columns null; matched rows have weather populated where available.

## Research questions and findings (executive story)

- RQ1 — Trip spatial and time patterns: Longer or slower trips tend to earn higher tips. Short, quick hops earn less. Where a trip starts and ends also matters: airport‑ and nightlife‑adjacent areas skew higher, while some commuter zones skew lower.

- RQ2 — Temporal factors: Tipping follows a daily rhythm—early‑morning hours perform best, the evening commute is softer. Weekends are generally more generous than weekdays, and fall edges out winter. Weather matters but its signal is smaller than everyday timing patterns.

- RQ3 — Fare components within similar trips: Even comparing like‑for‑like trips (similar distance and duration), the presence of tolls, congestion surcharges, or an airport fee aligns with higher tips, with the strongest lift typically on tolled routes. These markers capture trip context (airport runs, heavy traffic, express routes) that riders seem to value.

Taken together, tipping reflects perceived time, context, and purpose of a ride. Longer or more involved trips, airport connections, tolled routes, and off‑peak/weekend travel align with more generous tipping. This suggests practical guidance for drivers (airport windows, early‑morning/weekend demand, routes likely to include express/tolled segments) and for operators (surfacing guidance, setting expectations in‑app, and aligning incentives where tipping potential is structurally higher).

## Outputs

- Figures: `docs/figures/*.png` (e.g., `rq1_heatmap_tip_percent.png`, `rq2_hour_tip_pct.png`, `rq3_withinbin_deltas.png`).
- Tables: `docs/tables/*.csv` for RQ aggregations (bins, temporal splits, within‑bin deltas).
- Report blocks (markdown): `docs/report_blocks/` → `rq1_summary.md`, `rq2_summary.md`, `rq3_summary.md`, `executive_summary.md`.

## Version control workflow

- Work on `dev` branch; merge to `main` via PR.  
- This README reflects the finalized analysis (Notebook 04 completed and exports in place).
