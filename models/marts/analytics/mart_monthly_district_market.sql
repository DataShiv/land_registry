with transactions as (

    select
        fact.transaction_id,
        fact.sale_price,
        fact.property_type,
        fact.is_new_build,
        fact.tenure,
        fact.transaction_category,
        date_dimension.month_start_date as transaction_month,
        location_dimension.district

    from {{ ref('fct_property_transactions') }} as fact

    inner join {{ ref('dim_date') }} as date_dimension
        on fact.transaction_date_key = date_dimension.date_key

    inner join {{ ref('dim_location') }} as location_dimension
        on fact.location_key = location_dimension.location_key

),

aggregated as (

    select
        transaction_month,
        district,
        property_type,

        count(*) as transaction_count,
        sum(sale_price) as total_sales_value,
        avg(sale_price) as average_sale_price,
        median(sale_price) as median_sale_price,
        min(sale_price) as minimum_sale_price,
        max(sale_price) as maximum_sale_price,

        percentile_cont(0.25) within group (
            order by sale_price
        ) as lower_quartile_sale_price,

        percentile_cont(0.75) within group (
            order by sale_price
        ) as upper_quartile_sale_price,

        count_if(is_new_build = true)
            as new_build_transaction_count,

        count_if(is_new_build = true)::float
            / nullif(count(*), 0)
            as new_build_share,

        count_if(tenure = 'Freehold')
            as freehold_transaction_count,

        count_if(tenure = 'Leasehold')
            as leasehold_transaction_count,

        count_if(tenure = 'Freehold')::float
            / nullif(count(*), 0)
            as freehold_share,

        count_if(tenure = 'Leasehold')::float
            / nullif(count(*), 0)
            as leasehold_share

    from transactions

    where district is not null

    group by
        transaction_month,
        district,
        property_type

)

select *
from aggregated