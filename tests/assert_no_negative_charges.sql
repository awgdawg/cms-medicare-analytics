-- Charges and payments should always be non-negative.
-- Returns rows that violate this — empty result = test pass.

SELECT
    provider_sk,
    procedure_sk,
    year,
    avg_covered_charges,
    avg_total_payments
FROM {{ ref('fact_provider_procedure_year') }}
WHERE avg_covered_charges < 0
   OR avg_total_payments < 0
