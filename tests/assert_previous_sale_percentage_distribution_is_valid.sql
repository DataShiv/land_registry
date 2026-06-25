select *

from {{ ref('mart_previous_sale_performance') }}

where lower_quartile_percentage_price_change
        > median_percentage_price_change

   or median_percentage_price_change
        > upper_quartile_percentage_price_change