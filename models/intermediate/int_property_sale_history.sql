with staged_transactions as (

    select *
    from {{ ref('stg_price_paid') }}

    where is_valid_transaction_id = true
      and is_valid_price = true
      and is_valid_date = true
      and transaction_id is not null
      and sale_price is not null
      and transaction_date is not null

),

normalised_addresses as (

    select
        *,

        nullif(
            upper(regexp_replace(trim(paon), '\\s+', ' ')),
            ''
        ) as normalised_paon,

        nullif(
            upper(regexp_replace(trim(saon), '\\s+', ' ')),
            ''
        ) as normalised_saon,

        nullif(
            upper(regexp_replace(trim(street), '\\s+', ' ')),
            ''
        ) as normalised_street

    from staged_transactions

),

property_identifiers as (

    select
        *,

        case
            when postcode is not null
             and normalised_paon is not null
            then concat_ws(
                '|',
                postcode,
                normalised_paon,
                coalesce(normalised_saon, ''),
                coalesce(normalised_street, '')
            )
        end as property_identifier

    from normalised_addresses

),

previous_sales as (

    select
        *,

        lag(transaction_date) over (
            partition by coalesce(
                property_identifier,
                concat('UNMATCHED|', transaction_id)
            )
            order by transaction_date, transaction_id
        ) as previous_observed_sale_date,

        lag(sale_price) over (
            partition by coalesce(
                property_identifier,
                concat('UNMATCHED|', transaction_id)
            )
            order by transaction_date, transaction_id
        ) as previous_observed_sale_price

    from property_identifiers

),

final as (

    select
        transaction_id,
        sale_price,
        transaction_date,

        postcode,
        paon,
        saon,
        street,
        locality,
        town_city,
        district,
        county,

        property_type,
        is_new_build,
        tenure,
        transaction_category,
        record_status,

        property_identifier,

        previous_observed_sale_date,
        previous_observed_sale_price,

        previous_observed_sale_date is not null
            as has_previous_observed_sale,

        case
            when previous_observed_sale_price is not null
            then sale_price - previous_observed_sale_price
        end as absolute_price_change,

        case
            when previous_observed_sale_price > 0
            then (
                sale_price - previous_observed_sale_price
            ) / previous_observed_sale_price
        end as percentage_price_change,

        case
            when previous_observed_sale_date is not null
            then datediff(
                day,
                previous_observed_sale_date,
                transaction_date
            )
        end as holding_period_days,

        source_file_name,
        source_file_row_number,
        loaded_at

    from previous_sales

)

select *
from final