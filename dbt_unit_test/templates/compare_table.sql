{% macro compare_table(model1, model2) %}
	{% if not execute %}
		{{ return('') }}
	{% endif %}
	{% set diff = adapter.get_missing_columns(model1, model2) %}
	{% for i in diff %}
		{{ return(-1) }}
	{% endfor %}
	{% set diff = adapter.get_missing_columns(model2, model1) %}
	{% for i in diff %}
		{{ return(-1) }}
	{% endfor %}
	{% set columns = adapter.get_columns_in_relation(model1) %}
	{% for i in columns %}
		{% if compare_table_column(model1, model2, adapter.quote(i.column)|trim) != 0 %}
			{{ return(1) }}
		{% endif %}
	{% endfor %}
	{{ return(0) }}
{% endmacro %}

{#
	使用说明:
		使用方法: compare_table(model1, model2)
		函数作用: 比较两个模型是否完全相同(结构相同且内容相同)
		返回: 两个模型结构不同时返回-1，内容不同时返回1，内容相同时返回0
		参数: model1 -要比较的第一个模型
		      model2 -要比较的第二个模型
#}
