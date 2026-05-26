-- Cost-payment ratio should be non-negative wherever defined.
-- Returns rows that violate this — empty result = test pass.

SELECT
    provider_sk,
    procedure_sk,
    year,
    cost_payment_ratio
FROM {{ ref('fact_provider_procedure_year') }}
WHERE cost_payment_ratio < 0
