select
    transaction_month,
    district,
    property_type,
    count(*) as row_count

from {{ ref('mart_previous_sale_performance') }}

group by
    transaction_month,
    district,
    property_type

having count(*) > 1