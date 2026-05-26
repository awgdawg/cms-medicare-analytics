{{ config(materialized='view') }}

WITH unioned AS (
    SELECT * FROM {{ ref('stg_cms__inpatient_charges') }}
    UNION ALL
    SELECT * FROM {{ ref('stg_cms__outpatient_charges') }}
),

parsed AS (
    SELECT
        provider_id,
        provider_name,
        provider_street,
        provider_city,
        provider_state,
        provider_zip,
        hospital_referral_region,

        -- procedure_code_raw is "<code> - <description>". Split into parts.
        TRIM(SPLIT(procedure_code_raw, ' - ')[SAFE_OFFSET(0)]) AS procedure_code,
        TRIM(
            ARRAY_TO_STRING(
                ARRAY(
                    SELECT x
                    FROM UNNEST(SPLIT(procedure_code_raw, ' - ')) AS x WITH OFFSET pos
                    WHERE pos > 0
                ),
                ' - '
            )
        )                                                       AS procedure_description,

        setting,
        year,
        total_services,
        avg_covered_charges,
        avg_total_payments,
        avg_medicare_payments
    FROM unioned
)

SELECT
    *,
    {{ cost_payment_ratio('avg_covered_charges', 'avg_total_payments') }} AS cost_payment_ratio
FROM parsed
