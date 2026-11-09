{% macro amount_bucket(column_name) %}
    case
        when {{ column_name }} < 50 then 'SMALL'
        when {{ column_name }} < 200 then 'MEDIUM'
        else 'LARGE'
    end
{% endmacro %}