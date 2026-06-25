with expected as (

    select
        sum(fact.sale_price) as expected_sales_value

    from {{ ref('fct_property_transactions') }} as fact

    inner join {{ ref('dim_location') }} as location
        on fact.location_key = location.location_key

    where location.district is not null

),

actual as (

    select
        sum(total_sales_value) as actual_sales_value

    from {{ ref('mart_monthly_district_market') }}

)

select
    expected.expected_sales_value,
    actual.actual_sales_value

from expected
cross join actual

where expected.expected_sales_value
    <> actual.actual_sales_value