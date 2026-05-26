{% macro format_currency(amount) %}
    CONCAT('$', FORMAT('%.0f', {{ amount }}))
{% endmacro %}
