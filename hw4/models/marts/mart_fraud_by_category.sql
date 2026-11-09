{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['category']
) }}

select
    category,
    count() as transaction_count,
    countIf(is_fraud = 1) as fraud_count,
    round(100 * countIf(is_fraud = 1) / count(), 2) as fraud_rate,
    round(sum(amount), 2) as total_amount,
    round(sumIf(amount, is_fraud = 1), 2) as fraud_amount
from {{ ref('stg_transactions') }}
group by category
