{{ config(materialized='table') }}

SELECT
    SUM(avg_covered_charges * total_services)    AS total_charges,
    SUM(avg_total_payments * total_services)     AS total_payments,
    {{ cost_payment_ratio(
        'SUM(avg_covered_charges * total_services)',
        'SUM(avg_total_payments * total_services)'
    ) }}                                          AS cost_payment_ratio,
    SUM(total_services)                          AS total_services
FROM {{ ref('fact_provider_procedure_year') }}
