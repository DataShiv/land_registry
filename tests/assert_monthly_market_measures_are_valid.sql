select *

from {{ ref('mart_monthly_district_market') }}

where transaction_count <= 0
   or total_sales_value <= 0
   or average_sale_price <= 0
   or median_sale_price <= 0
   or minimum_sale_price <= 0
   or maximum_sale_price <= 0
   or lower_quartile_sale_price <= 0
   or upper_quartile_sale_price <= 0