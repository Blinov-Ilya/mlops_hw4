{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['us_state']
) }}

select
    us_state,
    count() as transaction_count,
    countIf(is_fraud = 1) as fraud_count,
    round(100.0 * countIf(is_fraud = 1) / count(), 2) as fraud_rate,
    uniqExact(customer_id) as unique_customers,
    uniqExact(merchant) as unique_merchants,
    round(sum(amount), 2) as total_amount,
    round(sumIf(amount, is_fraud = 1), 2) as fraud_amount
from {{ ref('stg_transactions') }}
group by us_state