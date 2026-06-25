select *

from {{ ref('mart_previous_sale_performance') }}

where matched_transaction_count <= 0
   or median_previous_sale_price <= 0
   or median_current_sale_price <= 0
   or median_holding_period_days < 0
   or average_holding_period_days < 0