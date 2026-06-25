select
    transaction_month,
    district,
    property_type,
    count(*) as row_count

from {{ ref('mart_monthly_district_market') }}

group by
    transaction_month,
    district,
    property_type

having count(*) > 1