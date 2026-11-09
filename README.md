# dbt — Анализ мошеннических транзакций

Проект по анализу транзакций с использованием **dbt Core и ClickHouse**. Реализована слоистая архитектура преобразования данных, аналитические витрины, макросы, тестирование и документация.

## 1. Стек технологий

- Python 3.12
- dbt Core 1.12.6
- dbt-clickhouse 1.10.3
- ClickHouse
- uv

Используемые dbt-пакеты:
- `dbt_utils`
- `dbt_date`
- `dbt_expectations`

## 2. Архитектура проекта

```text
transactions_db.transactions (raw)
              |
              v
       stg_transactions
              |
      +-------+-------+
      |       |       |
      v       v       v
           marts
```

**Raw:** исходная таблица `transactions_db.transactions`, содержащая транзакции, информацию о клиентах, мерчантах и признак мошенничества.

**Staging:** модель `stg_transactions` выполняет нормализацию полей, приведение типов, создание идентификаторов клиентов, выделение даты и времени транзакций, сегментацию сумм.

**Marts:** аналитические таблицы, построенные на основе staging-модели.

## 3. Реализованные витрины

| Модель | Описание |
|---|---|
| `mart_daily_state_metrics` | Дневные метрики по штатам: количество, сумма, средний чек, P95, доля крупных транзакций |
| `mart_fraud_by_category` | Анализ фрода по категориям: количество транзакций, fraud rate, суммы |
| `mart_fraud_by_state` | Географический анализ: fraud rate, уникальные клиенты и мерчанты |
| `mart_customer_risk_profile` | Профиль клиентов: история транзакций, средний чек, сегментация HIGH/MEDIUM/LOW |

## 4. Макросы

Реализован пользовательский макрос `amount_bucket`, который классифицирует транзакции по сумме:

- `SMALL` — менее 50
- `MEDIUM` — от 50 до 200 (не включительно)
- `LARGE` — от 200

Макрос используется в модели `stg_transactions`.

## 5. Тестирование

Для проверки качества данных используются:

**Generic tests:**
- `not_null` — отсутствие NULL в ключевых полях
- `unique` — уникальность идентификаторов и ключей
- `accepted_values` — допустимые значения категориальных признаков
- `dbt_utils.unique_combination_of_columns` — уникальность комбинации даты и штата
- `dbt_expectations.expect_column_values_to_be_between` — проверка границ fraud rate

**Singular tests:**
- `assert_no_negative_amounts.sql` — отсутствие отрицательных сумм
- `assert_fraud_rate_bounds.sql` — fraud rate в диапазоне 0–100%

## 6. Запуск проекта

### Установка зависимостей

```bash
uv venv --python 3.12
source .venv/bin/activate

uv pip install "dbt-core>=1.8,<2" "dbt-clickhouse>=1.10,<2"
dbt deps
```

### Настройка окружения

Создать файл `.env.secrets` с параметрами подключения к ClickHouse:

```bash
DBT_HOST=localhost
DBT_PORT=8123
DBT_USER=default
DBT_ENV_SECRET_PASSWORD=''
DBT_SCHEMA=dbt_dev
DBT_TARGET=dev
```

Загрузить переменные окружения:

```bash
set -a
source .env.secrets
set +a
export DBT_PROFILES_DIR="$PWD"
```

Файл `.env.secrets` содержит конфиденциальные данные и не должен добавляться в Git.

Перед запуском необходимо создать базу `dbt_dev` в ClickHouse и загрузить исходную таблицу `transactions_db.transactions`.

### Основные команды

```bash
dbt debug
dbt deps
dbt run
dbt test
```

Полная сборка и тестирование:

```bash
dbt build
```

### Документация

```bash
dbt docs generate
dbt docs serve --port 8080
```

Документация доступна по адресу `http://localhost:8080`.

В интерфейсе dbt Docs можно изучить описания моделей и граф зависимостей (DAG).

## 7. Результат

Реализованы четыре аналитические витрины для исследования транзакций и мошенничества. Проект использует dbt для управления зависимостями, повторного использования SQL-логики, тестирования качества данных и формирования документации.

Каюсь, не успевал, readme написан чисто гпт, с ним разбирался, он должен был все правильно писать :)