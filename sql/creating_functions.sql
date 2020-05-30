CREATE OR REPLACE FUNCTION p_refresh_views() RETURNS trigger AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW vw_content_types;
    REFRESH MATERIALIZED VIEW vw_result_codes;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER refresh_views AFTER TRUNCATE OR INSERT
   ON files FOR EACH STATEMENT
   EXECUTE PROCEDURE p_refresh_views();

--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__
--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__

CREATE OR REPLACE FUNCTION top_domains(data_inicial date, data_final date)
  RETURNS TABLE
          (
            seq           bigint,
            netloc        dim_url.url_netloc%type,
            totalBytes    bigint,
            totalDuration bigint,
            nr_clients    bigint,
            nr_requests   bigint
          ) AS
$$
BEGIN
  RETURN QUERY
    SELECT row_number() over (), --as seq
           du.url_netloc,        --as netloc
           sum(f.bytes),         --as totalBytes
           sum(f.duration),      --as totalDuration
           count(f.client_id),   --as nr_clients
           count(f.url_id)       --as nr_requests
    FROM fact_request f
           JOIN dim_url du on f.url_id = du.url_dim_id
    WHERE EXISTS
            (SELECT *
             FROM dim_date dd
             WHERE (dd.date_actual BETWEEN data_inicial AND data_final)
               AND dd.date_dim_id = f.date_id)
    GROUP BY du.url_netloc, f.url_id
    ORDER BY f.url_id DESC
    LIMIT 10;
END
$$ LANGUAGE plpgsql;

drop FUNCTION top_domains;

select * from top_domains('2019-03-01'::date, '2019-05-31'::date);



-- ####################################################

CREATE OR REPLACE FUNCTION feed_tables(
  p_date text,
  p_time text,
  p_content_type dim_content_type.type%type,
  p_user dim_user.type%type,
  p_hierarchy_codes dim_hierarchy_codes.type%type,
  p_url dim_url.url_netloc%type,
  p_result_codes dim_result_codes.type%type,
  p_method dim_method.type%type,
  p_client dim_client.client_address%type,
  p_duration integer,
  p_bytes integer,
  p_scheme fact_request.url_scheme%type,
  p_path text,
  p_params text) RETURNS void AS
$$

DECLARE
  tmp_client    bigint;
  tmp_cont_type bigint;
  tmp_date      bigint;
  tmp_codes     bigint;
  tmp_method    bigint;
  tmp_result    bigint;
  tmp_time      bigint;
  tmp_url       bigint;
  tmp_user      bigint;
  tmp_epoch     bigint;
  tmp_hour      int;

BEGIN

  -- cliente
  select client_dim_id
  from dim_client d
  where d.client_address = p_client into tmp_client;
  if tmp_client is null then
    insert into dim_client values (default, p_client) returning client_dim_id into tmp_client;
  end if;

  -- content type
  select content_type_dim_id
  from dim_content_type d
  where d.type = p_content_type into tmp_cont_type;
  if tmp_cont_type is null then
    insert into dim_content_type values (default, p_content_type) returning content_type_dim_id into tmp_cont_type;
  end if;

  -- hierarchy codes
  select hierarchy_codes_dim_id
  from dim_hierarchy_codes d
  where d.type = p_hierarchy_codes into tmp_codes;
  if tmp_codes is null then
    insert into dim_hierarchy_codes values (default, p_hierarchy_codes) returning hierarchy_codes_dim_id into tmp_codes;
  end if;

  -- request method
  select method_dim_id
  from dim_method d
  where d.type = coalesce(p_method, ' vazio') into tmp_method;
  if tmp_method is null then
    insert into dim_method values (default, coalesce(p_method, ' vazio')) returning method_dim_id into tmp_method;
  end if;

  -- result codes
  select result_codes_dim_id
  from dim_result_codes d
  where d.type = p_result_codes into tmp_result;
  if tmp_result is null then
    insert into dim_result_codes values (default, p_result_codes) returning result_codes_dim_id into tmp_result;
  end if;

  -- url
  select url_dim_id
  from dim_url d
  where d.url_netloc = p_url into tmp_url;
  if tmp_url is null then
    insert into dim_url values (default, p_url) returning url_dim_id into tmp_url;
  end if;

  -- user
  select user_dim_id
  from dim_user d
  where d.type = p_user into tmp_user;
  if tmp_user is null then
    insert into dim_user values (default, p_user) returning user_dim_id into tmp_user;
  end if;

  -- date
  tmp_epoch = date_part('epoch'::TEXT, p_date::TIMESTAMP);
  select date_dim_id
  from dim_date d
  where d.date_dim_id = tmp_epoch into tmp_date;
  if tmp_date is null then
    insert into dim_date
    SELECT EXTRACT(epoch FROM datum)                                         AS date_dim_id,
           datum                                                             AS date_actual,
           TO_CHAR(datum, 'fmDDth')                                          AS day_suffix,
           TO_CHAR(datum, 'Day')                                             AS day_name,
           EXTRACT(isodow FROM datum)                                        AS day_of_week,
           EXTRACT(DAY FROM datum)                                           AS day_of_month,
           datum - DATE_TRUNC('quarter', datum)::DATE + 1                    AS day_of_quarter,
           EXTRACT(doy FROM datum)                                           AS day_of_year,
           TO_CHAR(datum, 'W')::INT                                          AS week_of_month,
           EXTRACT(week FROM datum)                                          AS week_of_year,
           TO_CHAR(datum, 'YYYY"-W"IW-') || EXTRACT(isodow FROM datum)       AS week_of_year_iso,
           EXTRACT(MONTH FROM datum)                                         AS month_actual,
           TO_CHAR(datum, 'Month')                                           AS month_name,
           TO_CHAR(datum, 'Mon')                                             AS month_name_abbreviated,
           EXTRACT(quarter FROM datum)                                       AS quarter_actual,
           CASE
             WHEN EXTRACT(quarter FROM datum) = 1 THEN 'Primeiro'
             WHEN EXTRACT(quarter FROM datum) = 2 THEN 'Segundo'
             WHEN EXTRACT(quarter FROM datum) = 3 THEN 'Terceiro'
             WHEN EXTRACT(quarter FROM datum) = 4 THEN 'Quarto'
             END                                                             AS quarter_name,
           EXTRACT(isoyear FROM datum)                                       AS year_actual,
           datum + (1 - EXTRACT(isodow FROM datum))::INT                     AS first_day_of_week,
           datum + (7 - EXTRACT(isodow FROM datum))::INT                     AS last_day_of_week,
           datum + (1 - EXTRACT(DAY FROM datum))::INT                        AS first_day_of_month,
           (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE   AS last_day_of_month,
           DATE_TRUNC('quarter', datum)::DATE                                AS first_day_of_quarter,
           (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
           TO_DATE(EXTRACT(isoyear FROM datum) || '-01-01', 'YYYY-MM-DD')    AS first_day_of_year,
           TO_DATE(EXTRACT(isoyear FROM datum) || '-12-31', 'YYYY-MM-DD')    AS last_day_of_year,
           TO_CHAR(datum, 'mmyyyy')                                          AS mmyyyy,
           TO_CHAR(datum, 'mmddyyyy')                                        AS mmddyyyy,
           CASE
             WHEN EXTRACT(isodow FROM datum) IN (6, 7) THEN TRUE
             ELSE FALSE
             END                                                             AS weekend_indr
    FROM (SELECT p_date::DATE AS datum) DQ
    ORDER BY 1 returning date_dim_id into tmp_date;
  end if;

  -- time
  tmp_hour = TO_CHAR(p_time::time, 'HH24MISS'::text)::INT;
  select time_dim_id
  from dim_time d
  where d.time_dim_id = tmp_hour into tmp_time;
  if tmp_time is null then
    insert into dim_time
    SELECT TO_CHAR(datum, 'HH24MISS')::INT AS                         time_dim_id,
           datum::TIME                     AS                         time_type,
           TO_CHAR(datum, 'HH24:MI')       AS                         time_value,
           TO_CHAR(datum, 'HH24')          AS                         hour_24,
           TO_CHAR(datum, 'HH12')                                     hour_12,
           TO_CHAR(datum, 'MI')                                       hour_minutes,
           EXTRACT(hour FROM datum) * 60 + EXTRACT(minute FROM datum) day_minutes,
           -- Indicator of period of day
           CASE
             WHEN datum BETWEEN '06:00:00' and '12:00:00' THEN 'Manhã'
             WHEN datum BETWEEN '12:00:01' and '18:00:00' THEN 'Tarde'
             WHEN datum BETWEEN '18:00:01' and '00:00:00' THEN 'Noite'
             else 'Madrugada'
             END                           AS                         day_time_name,
           CASE
             WHEN datum BETWEEN '06:00:00' and '18:00:00' THEN 'Dia'
             else 'Noite'
             end                           AS                         day_night
    FROM (SELECT p_time::TIME AS datum) TM
    ORDER BY 1 returning time_dim_id into tmp_time;
  end if;

  insert into fact_request
  values (default, tmp_date, tmp_time, tmp_cont_type, tmp_user, tmp_codes, tmp_url, tmp_result, tmp_method, tmp_client, p_duration, p_bytes, p_scheme, p_path, p_params);


END;
$$ LANGUAGE plpgsql;



select feed_tables('2006-01-02', '04:05:03', 'plain/text', '-', 'aaaa', 'g1.com', '200/ok', 'GET', '10.10.10.5', '345', '3456', 'http', '', '');

--
-- #### USO DE FUNÇÃO ####
--     values_by_function = db.session.query(func.public.top_domains(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d")))
--
--     print(type(values_by_function))
--     for value in values_by_function:
--         print(value)
