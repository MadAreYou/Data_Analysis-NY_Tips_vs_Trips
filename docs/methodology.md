# Methodology – Data Sources & Merge Logic

### TLC Data Verification (Local Copy)

| File                            |   Size_MB |
|:--------------------------------|----------:|
| yellow_tripdata_2024-01.parquet |     49.96 |
| yellow_tripdata_2024-02.parquet |     50.35 |
| yellow_tripdata_2024-03.parquet |     60.08 |
| yellow_tripdata_2024-04.parquet |     59.13 |
| yellow_tripdata_2024-05.parquet |     62.55 |
| yellow_tripdata_2024-06.parquet |     59.86 |
| yellow_tripdata_2024-07.parquet |     52.3  |
| yellow_tripdata_2024-08.parquet |     51.07 |
| yellow_tripdata_2024-09.parquet |     61.17 |
| yellow_tripdata_2024-10.parquet |     64.35 |
| yellow_tripdata_2024-11.parquet |     60.66 |
| yellow_tripdata_2024-12.parquet |     61.52 |

Total files: 12 | Combined size: 693.0 MB

## NOAA Weather Data Ingestion Plan
Stations selected: KJFK (JFK Airport), KLGA (LaGuardia), KNYC (Central Park), KEWR (Newark), KTEB (Teterboro).

Hourly aggregation will produce a single city-wide dataset saved as:
`/data/interim/noaa_hourly_citywide_2024.parquet`.

Aggregation metrics follow the approved schema (mean / sum / mode per hour).
