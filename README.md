# CMS Medicare Analytics

Cost-vs-payment ratio analysis on Medicare inpatient + outpatient charge data, 2011–2015. dbt-bigquery project with Kimball-style star schema feeding a public Looker Studio dashboard.

**Dashboard:** _to be added when published_
**Lineage:** see `docs/lineage.png`

## Headline findings

From the latest `dbt build`:

- **National cost-payment ratio: 3.92×** — hospitals charge roughly $3.92 for every $1 Medicare actually pays.
- **Top procedure gap: 8.52×** (outpatient APC 0336).
- **Top state: New Jersey at 6.30×** (closely followed by Nevada and Florida).
- **188.8M services** modeled across 5 years.

## What this does

CMS publishes hospital-level Medicare claims with three key amounts per procedure:

- `average_covered_charges` — what the hospital *charges*
- `average_total_payments` — what is *actually paid* (Medicare + patient + secondary insurance)
- `average_medicare_payments` — the Medicare portion of that

This project models the gap: how much hospitals charge vs how much they actually get paid, sliced by procedure, geography, year, and inpatient-vs-outpatient setting.

## Stack

- [dbt-core](https://docs.getdbt.com/) 1.10 + [dbt-bigquery](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup) 1.10
- [BigQuery](https://cloud.google.com/bigquery) (sandbox tier — no billing required)
- [Looker Studio](https://lookerstudio.google.com/) for the dashboard
- GitHub Actions for CI

## Model structure

```
sources (10 public CMS tables)
  ↓
staging (views: stg_cms__inpatient_charges, stg_cms__outpatient_charges)
  ↓
intermediate (view: int_provider_procedure_unioned)
  ↓
dimensions (tables: dim_provider, dim_procedure, dim_geography, dim_setting)
  ↓
fact (table: fact_provider_procedure_year — 1.1M rows)
  ↓
analytics marts (tables: mart_national_ratio, mart_yearly_trend,
                          mart_top_procedures, mart_state_ratio,
                          mart_setting_comparison)
```

13 models, 4 of them dims, surrogate keys via `dbt_utils.generate_surrogate_key`. Singular tests cover negative charges and ratio sanity. Total test count: 64.

## Running locally

```bash
# 1. Set up a Python venv and install dbt
python -m venv .venv
.venv\Scripts\Activate.ps1   # PowerShell on Windows
pip install -r requirements.txt

# 2. Configure your dbt profile (see profiles.yml.example)
#    Copy profiles.yml.example to ~/.dbt/profiles.yml and fill in keyfile path.

# 3. Build everything
dbt deps
dbt seed
dbt build
```

## CI

GitHub Actions runs `dbt build` on every push. The service account key is stored as the `GCP_SA_KEY` repo secret.

## License

MIT.
