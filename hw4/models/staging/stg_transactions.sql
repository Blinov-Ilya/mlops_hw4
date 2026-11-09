with source as (
    select *
    from {{ source('transactions_db', 'transactions') }}
),
renamed as (
    select
        transaction_time,
        merch as merchant,
        cat_id as category,
        amount,
        name_1,
        name_2,
        gender,
        us_state,
        street, 
        post_code,
        cityHash64(name_1, name_2, street, post_code) as customer_id,
        lat,
        lon,
        merchant_lat,
        merchant_lon,
        target as is_fraud,
        toDate(transaction_time) AS transaction_date,
        toHour(transaction_time) AS transaction_hour,
        toDayOfWeek(transaction_time) AS day_of_week,
        {{ amount_bucket('amount') }} AS amount_bucket
    from source
)
select *
from renamed