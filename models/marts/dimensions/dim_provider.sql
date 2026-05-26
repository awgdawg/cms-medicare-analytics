{{ config(materialized='table') }}

WITH ranked AS (
    SELECT
        provider_id,
        provider_name,
        provider_street,
        provider_city,
        provider_state,
        provider_zip,
        hospital_referral_region,
        ROW_NUMBER() OVER (PARTITION BY provider_id ORDER BY year DESC) AS rn
    FROM {{ ref('int_provider_procedure_unioned') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['provider_id']) }} AS provider_sk,
    provider_id,
    provider_name,
    provider_street,
    provider_city,
    provider_state,
    provider_zip,
    hospital_referral_region
FROM ranked
WHERE rn = 1
