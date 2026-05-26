{% macro cost_payment_ratio(charges, payments) %}
    SAFE_DIVIDE({{ charges }}, NULLIF({{ payments }}, 0))
{% endmacro %}
