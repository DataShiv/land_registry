with expected as (

    select
        count(*) as expected_transaction_count

    from {{ ref('fct_property_transactions') }} as fact

    inner join {{ ref('dim_location') }} as location
        on fact.location_key = location.location_key

    where location.district is not null

),

actual as (

    select
        sum(transaction_count) as actual_transaction_count

    from {{ ref('mart_monthly_district_market') }}

)

select
    expected.expected_transaction_count,
    actual.actual_transaction_count

from expected
cross join actual

where expected.expected_transaction_count
    <> actual.actual_transaction_count