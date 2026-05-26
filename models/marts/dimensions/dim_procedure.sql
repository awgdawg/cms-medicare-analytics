{{ config(materialized='table') }}

WITH ranked AS (
    SELECT
        procedure_code,
        procedure_description,
        setting,
        ROW_NUMBER() OVER (PARTITION BY procedure_code, setting ORDER BY year DESC) AS rn
    FROM {{ ref('int_provider_procedure_unioned') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['procedure_code', 'setting']) }} AS procedure_sk,
    procedure_code,
    procedure_description,
    setting
FROM ranked
WHERE rn = 1
