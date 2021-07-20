{% macro test_diff(model, test) %}
select {{ compare_table(model, test) }}
{% endmacro %}
