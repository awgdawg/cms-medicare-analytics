{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ ref('int_provider_procedure_unioned') }}
),

joined AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['s.provider_id']) }}                       AS provider_sk,
        {{ dbt_utils.generate_surrogate_key(['s.procedure_code', 's.setting']) }}       AS procedure_sk,
        {{ dbt_utils.generate_surrogate_key(['s.provider_state']) }}                    AS geo_sk,
        {{ dbt_utils.generate_surrogate_key(['s.setting']) }}                           AS setting_sk,
        s.year,
        s.total_services,
        s.avg_covered_charges,
        s.avg_total_payments,
        s.avg_medicare_payments,
        s.cost_payment_ratio
    FROM source s
)

SELECT * FROM joined
