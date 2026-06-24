with source as (

    select *
    from {{ source('land_registry', 'price_paid') }}

),

renamed_and_cleaned as (

    select
        nullif(
            trim(replace(replace(transaction_id_raw, '{', ''), '}', '')),
            ''
        ) as transaction_id,

        try_to_number(
            nullif(trim(price_raw), '')
        ) as sale_price,

        try_to_date(
            left(nullif(trim(transfer_date_raw), ''), 10),
            'YYYY-MM-DD'
        ) as transaction_date,

        nullif(
            upper(regexp_replace(trim(postcode_raw), '\\s+', ' ')),
            ''
        ) as postcode,

        nullif(trim(paon_raw), '') as paon,
        nullif(trim(saon_raw), '') as saon,
        nullif(trim(street_raw), '') as street,
        nullif(trim(locality_raw), '') as locality,
        nullif(trim(town_city_raw), '') as town_city,
        nullif(trim(district_raw), '') as district,
        nullif(trim(county_raw), '') as county,

        nullif(upper(trim(property_type_code_raw)), '')
            as property_type_code,

        nullif(upper(trim(old_new_code_raw)), '')
            as old_new_code,

        nullif(upper(trim(duration_code_raw)), '')
            as tenure_code,

        nullif(upper(trim(ppd_category_type_raw)), '')
            as transaction_category_code,

        nullif(upper(trim(record_status_code_raw)), '')
            as record_status_code,

        source_file_name,
        source_file_row_number,
        loaded_at

    from source

),

decoded as (

    select
        transaction_id,
        sale_price,
        transaction_date,
        postcode,

        case property_type_code
            when 'D' then 'Detached'
            when 'S' then 'Semi-detached'
            when 'T' then 'Terraced'
            when 'F' then 'Flat'
            when 'O' then 'Other'
            else 'Unknown'
        end as property_type,

        case old_new_code
            when 'Y' then true
            when 'N' then false
            else null
        end as is_new_build,

        case tenure_code
            when 'F' then 'Freehold'
            when 'L' then 'Leasehold'
            when 'U' then 'Unknown'
            else 'Unknown'
        end as tenure,

        paon,
        saon,
        street,
        locality,
        town_city,
        district,
        county,

        case transaction_category_code
            when 'A' then 'Standard'
            when 'B' then 'Additional'
            else 'Unknown'
        end as transaction_category,

        case record_status_code
            when 'A' then 'Added'
            when 'C' then 'Changed'
            when 'D' then 'Deleted'
            else null
        end as record_status,

        property_type_code,
        old_new_code,
        tenure_code,
        transaction_category_code,
        record_status_code,

        source_file_name,
        source_file_row_number,
        loaded_at

    from renamed_and_cleaned

),

final as (

    select
        transaction_id,
        sale_price,
        transaction_date,
        postcode,
        property_type,
        is_new_build,
        tenure,
        paon,
        saon,
        street,
        locality,
        town_city,
        district,
        county,
        transaction_category,
        record_status,

        transaction_id is not null as is_valid_transaction_id,

        sale_price is not null
            and sale_price > 0 as is_valid_price,

        transaction_date is not null as is_valid_date,

        property_type_code,
        old_new_code,
        tenure_code,
        transaction_category_code,
        record_status_code,

        source_file_name,
        source_file_row_number,
        loaded_at

    from decoded

)

select *
from final