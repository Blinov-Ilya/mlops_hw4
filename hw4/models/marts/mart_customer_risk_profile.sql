{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['customer_id']
) }}

with customer_metrics as (
    select
        customer_id,
        any(name_1) as first_name,
        any(name_2) as last_name,
        count() as transaction_count,
        countIf(is_fraud = 1) as fraud_count,
        round(100.0 * countIf(is_fraud = 1) / count(), 2) as fraud_rate,
        round(sum(amount), 2) as total_amount,
        round(avg(amount), 2) as avg_amount,
        min(transaction_time) as first_transaction,
        max(transaction_time) as last_transaction
    from {{ ref('stg_transactions') }}
    group by customer_id
)
select
    *,
    case
        when fraud_rate >= 10 then 'HIGH'
        when fraud_rate >= 2 then 'MEDIUM'
        else 'LOW'
    end as risk_level
from customer_metrics