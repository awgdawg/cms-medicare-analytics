{{ config(materialized='table') }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['state_code']) }} AS geo_sk,
    state_code,
    state_name,
    census_region,
    census_division
FROM {{ ref('state_to_region') }}
