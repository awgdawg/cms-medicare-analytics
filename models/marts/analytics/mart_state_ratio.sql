{{ config(materialized='table') }}

SELECT
    g.state_code                                                       AS provider_state,
    g.state_name,
    g.census_region,
    COUNT(DISTINCT f.provider_sk)                                      AS num_providers,
    SUM(f.total_services)                                              AS total_services,
    SAFE_DIVIDE(SUM(f.avg_covered_charges * f.total_services),
                SUM(f.total_services))                                 AS avg_charges,
    SAFE_DIVIDE(SUM(f.avg_total_payments * f.total_services),
                SUM(f.total_services))                                 AS avg_payments,
    {{ cost_payment_ratio(
        'SUM(f.avg_covered_charges * f.total_services)',
        'SUM(f.avg_total_payments * f.total_services)'
    ) }}                                                                AS cost_payment_ratio
FROM {{ ref('fact_provider_procedure_year') }} f
JOIN {{ ref('dim_geography') }} g USING (geo_sk)
GROUP BY 1, 2, 3
ORDER BY cost_payment_ratio DESC
