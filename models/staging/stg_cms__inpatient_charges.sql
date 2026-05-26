{{ config(materialized='view') }}

{% set years = var('years') %}

{% for year in years %}
SELECT
    provider_id,
    provider_name,
    provider_street_address                    AS provider_street,
    provider_city,
    provider_state,
    provider_zipcode                           AS provider_zip,
    hospital_referral_region_description       AS hospital_referral_region,
    drg_definition                             AS procedure_code_raw,
    'inpatient'                                AS setting,
    {{ year }}                                 AS year,
    total_discharges                           AS total_services,
    average_covered_charges                    AS avg_covered_charges,
    average_total_payments                     AS avg_total_payments,
    average_medicare_payments                  AS avg_medicare_payments
FROM {{ source('cms_medicare', 'inpatient_charges_' ~ year) }}
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
