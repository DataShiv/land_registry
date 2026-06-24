with date_bounds as (

    select
        min(transaction_date) as minimum_date,
        max(transaction_date) as maximum_date
    from {{ ref('int_property_sale_history') }}

),

generated_numbers as (

    select
        row_number() over (order by seq4()) - 1 as day_offset
    from table(generator(rowcount => 50000))

),

date_spine as (

    select
        dateadd(
            day,
            generated_numbers.day_offset,
            date_bounds.minimum_date
        )::date as calendar_date

    from generated_numbers
    cross join date_bounds

    where dateadd(
        day,
        generated_numbers.day_offset,
        date_bounds.minimum_date
    ) <= date_bounds.maximum_date

),

final as (

    select
        to_number(to_char(calendar_date, 'YYYYMMDD')) as date_key,
        calendar_date,

        dayofweekiso(calendar_date) as day_of_week_number,
        dayname(calendar_date) as day_name,

        day(calendar_date) as day_of_month,
        weekiso(calendar_date) as week_of_year,

        month(calendar_date) as month_number,
        monthname(calendar_date) as month_name,

        quarter(calendar_date) as quarter_number,
        year(calendar_date) as calendar_year,

        case
            when month(calendar_date) >= 4
                then year(calendar_date)
            else year(calendar_date) - 1
        end as financial_year_start,

        case
            when month(calendar_date) >= 4
                then year(calendar_date) + 1
            else year(calendar_date)
        end as financial_year_end,

        date_trunc('month', calendar_date)::date
            as month_start_date,

        last_day(calendar_date, 'month')::date
            as month_end_date,

        date_trunc('quarter', calendar_date)::date
            as quarter_start_date,

        date_trunc('year', calendar_date)::date
            as year_start_date

    from date_spine

)

select *
from final