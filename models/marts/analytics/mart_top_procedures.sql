{{ config(materialized='table') }}

WITH agg AS (
    SELECT
        p.procedure_code,
        p.procedure_description,
        p.setting,
        SUM(f.total_services)                                        AS total_services,
        SAFE_DIVIDE(SUM(f.avg_covered_charges * f.total_services),
                    SUM(f.total_services))                           AS avg_charges,
        SAFE_DIVIDE(SUM(f.avg_total_payments * f.total_services),
                    SUM(f.total_services))                           AS avg_payments,
        {{ cost_payment_ratio(
            'SUM(f.avg_covered_charges * f.total_services)',
            'SUM(f.avg_total_payments * f.total_services)'
        ) }}                                                          AS cost_payment_ratio
    FROM {{ ref('fact_provider_procedure_year') }} f
    JOIN {{ ref('dim_procedure') }} p USING (procedure_sk)
    WHERE f.total_services >= 100
    GROUP BY 1, 2, 3
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY setting ORDER BY cost_payment_ratio DESC) AS rnk
    FROM agg
)

SELECT
    procedure_code,
    procedure_description,
    setting,
    total_services,
    avg_charges,
    avg_payments,
    cost_payment_ratio
FROM ranked
WHERE rnk <= 20
ORDER BY setting, rnk
