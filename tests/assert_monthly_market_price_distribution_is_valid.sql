select *

from {{ ref('mart_monthly_district_market') }}

where minimum_sale_price > lower_quartile_sale_price
   or lower_quartile_sale_price > median_sale_price
   or median_sale_price > upper_quartile_sale_price
   or upper_quartile_sale_price > maximum_sale_price