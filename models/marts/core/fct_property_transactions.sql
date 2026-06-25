with transactions as (

    select *
    from {{ ref('int_property_sale_history') }}

),

date_dimension as (

    select
        date_key,
        calendar_date
    from {{ ref('dim_date') }}

),

location_dimension as (

    select
        location_key,
        postcode
    from {{ ref('dim_location') }}

),

final as (

    select
        transactions.transaction_id,

        transaction_date_dimension.date_key
            as transaction_date_key,

        previous_sale_date_dimension.date_key
            as previous_sale_date_key,

        location_dimension.location_key,

        transactions.property_type,
        transactions.is_new_build,
        transactions.tenure,
        transactions.transaction_category,

        transactions.sale_price,

        transactions.property_identifier,

        transactions.has_previous_observed_sale,
        transactions.previous_observed_sale_price,

        transactions.absolute_price_change,
        transactions.percentage_price_change,
        transactions.holding_period_days,

        transactions.source_file_name,
        transactions.source_file_row_number,
        transactions.loaded_at

    from transactions

    left join date_dimension as transaction_date_dimension
        on transactions.transaction_date
            = transaction_date_dimension.calendar_date

    left join date_dimension as previous_sale_date_dimension
        on transactions.previous_observed_sale_date
            = previous_sale_date_dimension.calendar_date

    left join location_dimension
        on transactions.postcode
            = location_dimension.postcode

)

select *
from final