

PESQUISAS EM SQL:

---getTopClients

EXPLAIN ANALYZE SELECT dim_client.client_address,
       sum(fact_request.duration) AS sum_1,
       sum(fact_request.bytes) AS sum_2,
       count(fact_request.client_id) AS count_1,
       count(DISTINCT fact_request.url_id) AS count_2
FROM dim_client JOIN fact_request ON fact_request.client_id = dim_client.client_dim_id
WHERE EXISTS (SELECT 1
FROM dim_date
WHERE dim_date.date_actual BETWEEN '2018-04-02'::date AND '2018-04-23'::date
  AND dim_date.date_dim_id = fact_request.date_id)
GROUP BY dim_client.client_address, fact_request.client_id
ORDER BY count(fact_request.client_id) DESC;


EXPLAIN ANALYZE WITH cte_by_time AS (SELECT dim_date.date_dim_id
FROM dim_date
WHERE dim_date.date_actual BETWEEN '2018-04-02'::date AND '2018-04-23'::date)

SELECT dim_client.client_address,
       sum(fact_request.duration) AS sum_1,
       sum(fact_request.bytes) AS sum_2,
       count(fact_request.client_id) AS count_1,
       count(DISTINCT fact_request.url_id) AS count_2
FROM dim_client JOIN fact_request ON fact_request.client_id = dim_client.client_dim_id
JOIN cte_by_time ON cte_by_time.date_dim_id = fact_request.date_id
GROUP BY dim_client.client_address, fact_request.client_id
ORDER BY count(fact_request.client_id) DESC;
