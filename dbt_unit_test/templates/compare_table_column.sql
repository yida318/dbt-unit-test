{% macro compare_table_column(model1, model2, column_name='time') %}
	{% if execute %}
		{% set compare_query %}
			select arrayCount( x -> x!=0,
					   arrayMap( x, y -> x!=y,
						     arraySort(groupArray(a.{{ column_name }})),
						     arraySort(groupArray(b.{{ column_name }}))
					   )
			       )
			from ( select rowNumberInAllBlocks() as tjoinid, * from {{ model1 }} ) as a
			full join( select rowNumberInAllBlocks() as tjoinid, * from {{ model2 }} ) as b on a.tjoinid = b.tjoinid
		{% endset %}
		{% set result = run_query(compare_query) %}
		{% if result == None %}
			{{ return(-1) }}
		{% else %}
			{{ return(result.columns[0].values()[0]) }}
		{% endif %}
	{% endif %}
{% endmacro %}

{#
	此函数被compare_table macro调用，用于具体比较一列是否相同
#}
