{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['transaction_date', 'us_state']
) }}

select
    transaction_date,
    us_state,
    count() as transaction_count,
    sum(amount) as total_amount,
    avg(amount) as avg_amount,
    quantile(0.95)(amount) as p95_amount,
    countIf(amount_bucket = 'LARGE') / count() as large_transaction_pct

from {{ ref('stg_transactions') }}

group by
    transaction_date,
    us_state
