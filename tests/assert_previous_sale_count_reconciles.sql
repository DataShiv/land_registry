with expected as (

    select
        count(*) as expected_matched_transaction_count

    from {{ ref('fct_property_transactions') }} as fact

    inner join {{ ref('dim_location') }} as location
        on fact.location_key = location.location_key

    where fact.has_previous_observed_sale = true
      and fact.previous_observed_sale_price is not null
      and fact.holding_period_days is not null
      and location.district is not null

),

actual as (

    select
        sum(matched_transaction_count)
            as actual_matched_transaction_count

    from {{ ref('mart_previous_sale_performance') }}

)

select
    expected.expected_matched_transaction_count,
    actual.actual_matched_transaction_count

from expected
cross join actual

where expected.expected_matched_transaction_count
    <> actual.actual_matched_transaction_count