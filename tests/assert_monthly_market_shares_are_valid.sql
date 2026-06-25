select *

from {{ ref('mart_monthly_district_market') }}

where new_build_share not between 0 and 1
   or freehold_share not between 0 and 1
   or leasehold_share not between 0 and 1