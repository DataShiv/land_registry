with locations as (

    select
        postcode,
        town_city,
        district,
        county,
        transaction_date,
        loaded_at,
        transaction_id

    from {{ ref('int_property_sale_history') }}

    where postcode is not null

),

latest_location_attributes as (

    select
        postcode,
        town_city,
        district,
        county

    from locations

    qualify row_number() over (
        partition by postcode
        order by
            transaction_date desc,
            loaded_at desc,
            transaction_id desc
    ) = 1

),

final as (

    select
        postcode as location_key,
        postcode,

        split_part(postcode, ' ', 1)
            as postcode_district,

        town_city,
        district,
        county

    from latest_location_attributes

)

select *
from final