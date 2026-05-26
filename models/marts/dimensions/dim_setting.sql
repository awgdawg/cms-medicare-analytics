{{ config(materialized='table') }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['setting_code']) }} AS setting_sk,
    setting_code,
    setting_name,
    description
FROM (
    SELECT 'inpatient'  AS setting_code, 'Inpatient'  AS setting_name, 'Admitted to the hospital'        AS description
    UNION ALL
    SELECT 'outpatient' AS setting_code, 'Outpatient' AS setting_name, 'Treated without overnight stay'  AS description
)
