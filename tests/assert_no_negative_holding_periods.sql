select *
from {{ ref('int_property_sale_history') }}
where previous_observed_sale_date > transaction_date