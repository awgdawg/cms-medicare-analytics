-- Ad-hoc query: top 10 provider × procedure combos by cost-payment ratio
-- (filtered to procedures with at least 500 cumulative services to avoid noise).
-- Useful for the case study's "outlier detection" sidebar.

SELECT
    p.provider_name,
    p.provider_state,
    pr.procedure_code,
    pr.procedure_description,
    pr.setting,
    SUM(f.total_services) AS total_services,
    SAFE_DIVIDE(SUM(f.avg_covered_charges * f.total_services),
                SUM(f.total_services)) AS avg_charges,
    SAFE_DIVIDE(SUM(f.avg_total_payments * f.total_services),
                SUM(f.total_services)) AS avg_payments,
    {{ cost_payment_ratio(
        'SUM(f.avg_covered_charges * f.total_services)',
        'SUM(f.avg_total_payments * f.total_services)'
    ) }} AS cost_payment_ratio
FROM {{ ref('fact_provider_procedure_year') }} f
JOIN {{ ref('dim_provider') }} p USING (provider_sk)
JOIN {{ ref('dim_procedure') }} pr USING (procedure_sk)
GROUP BY 1, 2, 3, 4, 5
HAVING total_services >= 500
ORDER BY cost_payment_ratio DESC
LIMIT 10
