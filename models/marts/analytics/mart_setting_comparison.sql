{{ config(materialized='table') }}

SELECT
    s.setting_name                                                     AS setting,
    f.year,
    SUM(f.avg_covered_charges * f.total_services)                      AS total_charges,
    SUM(f.avg_total_payments * f.total_services)                       AS total_payments,
    {{ cost_payment_ratio(
        'SUM(f.avg_covered_charges * f.total_services)',
        'SUM(f.avg_total_payments * f.total_services)'
    ) }}                                                                AS cost_payment_ratio,
    SUM(f.total_services)                                              AS total_services
FROM {{ ref('fact_provider_procedure_year') }} f
JOIN {{ ref('dim_setting') }} s USING (setting_sk)
GROUP BY 1, 2
ORDER BY 1, 2
