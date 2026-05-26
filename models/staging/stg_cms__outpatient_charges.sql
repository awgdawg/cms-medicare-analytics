{{ config(materialized='view') }}

{% set years = var('years') %}

{% for year in years %}
SELECT
    provider_id,
    provider_name,
    provider_street_address                    AS provider_street,
    provider_city,
    provider_state,
    CAST(provider_zipcode AS STRING)           AS provider_zip,
    hospital_referral_region                   AS hospital_referral_region,
    apc                                        AS procedure_code_raw,
    'outpatient'                               AS setting,
    {{ year }}                                 AS year,
    outpatient_services                        AS total_services,
    average_estimated_submitted_charges        AS avg_covered_charges,
    average_total_payments                     AS avg_total_payments,
    CAST(NULL AS FLOAT64)                      AS avg_medicare_payments
FROM {{ source('cms_medicare', 'outpatient_charges_' ~ year) }}
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
