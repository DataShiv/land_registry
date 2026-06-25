with matched_transactions as (

    select
        fact.transaction_id,
        fact.sale_price,
        fact.previous_observed_sale_price,
        fact.absolute_price_change,
        fact.percentage_price_change,
        fact.holding_period_days,
        fact.property_type,
        date_dimension.month_start_date as transaction_month,
        location_dimension.district,

        case
            when fact.sale_price > 0
             and fact.previous_observed_sale_price > 0
             and fact.holding_period_days > 0
            then power(
                fact.sale_price / fact.previous_observed_sale_price,
                365.25 / fact.holding_period_days
            ) - 1
        end as annualised_price_change

    from {{ ref('fct_property_transactions') }} as fact

    inner join {{ ref('dim_date') }} as date_dimension
        on fact.transaction_date_key = date_dimension.date_key

    inner join {{ ref('dim_location') }} as location_dimension
        on fact.location_key = location_dimension.location_key

    where fact.has_previous_observed_sale = true
      and fact.previous_observed_sale_price is not null
      and fact.holding_period_days is not null
      and location_dimension.district is not null

),

aggregated as (

    select
        transaction_month,
        district,
        property_type,

        count(*) as matched_transaction_count,

        median(previous_observed_sale_price)
            as median_previous_sale_price,

        median(sale_price)
            as median_current_sale_price,

        median(absolute_price_change)
            as median_absolute_price_change,

        avg(absolute_price_change)
            as average_absolute_price_change,

        median(percentage_price_change)
            as median_percentage_price_change,

        avg(percentage_price_change)
            as average_percentage_price_change,

        percentile_cont(0.25) within group (
            order by percentage_price_change
        ) as lower_quartile_percentage_price_change,

        percentile_cont(0.75) within group (
            order by percentage_price_change
        ) as upper_quartile_percentage_price_change,

        median(holding_period_days)
            as median_holding_period_days,

        avg(holding_period_days)
            as average_holding_period_days,

        median(holding_period_days) / 365.25
            as median_holding_period_years,

        median(annualised_price_change)
            as median_annualised_price_change,

        avg(annualised_price_change)
            as average_annualised_price_change

    from matched_transactions

    group by
        transaction_month,
        district,
        property_type

)

select *
from aggregated