{{ config(materialized='view') }}

with base as(
	select	sum(a) as a,
		b
	from {{ ref('example_test_input') }}
	group by b
)

select * from base
