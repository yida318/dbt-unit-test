{% macro test_diff(model, test) %}
{% set columns = adapter.get_columns_in_relation(model) %}

{% do run_query('SET join_use_nulls = 1') %}

with extra_rows as(
	select 1
	from {{ model }} as table1
	left outer join {{ test }} as table2 on
	{% for i in columns %}
	table1.{{ adapter.quote(i.column)|trim }} = table2.{{ adapter.quote(i.column)|trim }}
	{% if not loop.last %}and{% endif %}
	{% endfor %}
	where table2.{{ adapter.quote(columns[0].column)|trim }} is null
),
missing_rows as(
	select 1
	from {{ test }} as table1
	left outer join {{ model }} as table2 on
	{% for i in columns %}
	table1.{{ adapter.quote(i.column)|trim }} = table2.{{ adapter.quote(i.column)|trim }}
	{% if not loop.last %}and{% endif %}
	{% endfor %}
	where table2.{{ adapter.quote(columns[0].column)|trim }} is null
)

select count(*)
from(
	select * from extra_rows union all select * from missing_rows
)
{% endmacro %}
