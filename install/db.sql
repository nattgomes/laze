--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1
-- Dumped by pg_dump version 11.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: laze; Type: DATABASE; Schema: -; Owner: laze
--

CREATE DATABASE laze WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE laze OWNER TO laze;

\connect laze

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: feed_tables(text, text, text, character varying, text, character varying, text, character varying, character varying, integer, integer, character varying, text, text); Type: FUNCTION; Schema: public; Owner: laze
--

CREATE FUNCTION public.feed_tables(p_date text, p_time text, p_content_type text, p_user character varying, p_hierarchy_codes text, p_url character varying, p_result_codes text, p_method character varying, p_client character varying, p_duration integer, p_bytes integer, p_scheme character varying, p_path text, p_params text) RETURNS void
    LANGUAGE plpgsql
    AS $$

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
$$;


ALTER FUNCTION public.feed_tables(p_date text, p_time text, p_content_type text, p_user character varying, p_hierarchy_codes text, p_url character varying, p_result_codes text, p_method character varying, p_client character varying, p_duration integer, p_bytes integer, p_scheme character varying, p_path text, p_params text) OWNER TO laze;

--
-- Name: p_refresh_views(); Type: FUNCTION; Schema: public; Owner: laze
--

CREATE FUNCTION public.p_refresh_views() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW vw_content_types;
    REFRESH MATERIALIZED VIEW vw_result_codes;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.p_refresh_views() OWNER TO laze;

--
-- Name: top_domains(date, date); Type: FUNCTION; Schema: public; Owner: laze
--

CREATE FUNCTION public.top_domains(data_inicial date, data_final date) RETURNS TABLE(seq bigint, netloc character varying, totalbytes bigint, totalduration bigint, nr_clients bigint, nr_requests bigint)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.top_domains(data_inicial date, data_final date) OWNER TO laze;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: dim_client; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_client (
    client_dim_id integer NOT NULL,
    client_address character varying(15) NOT NULL
);


ALTER TABLE public.dim_client OWNER TO laze;

--
-- Name: dim_client_client_dim_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.dim_client_client_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dim_client_client_dim_id_seq OWNER TO laze;

--
-- Name: dim_client_client_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.dim_client_client_dim_id_seq OWNED BY public.dim_client.client_dim_id;


--
-- Name: dim_content_type; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_content_type (
    content_type_dim_id integer NOT NULL,
    type text NOT NULL
);


ALTER TABLE public.dim_content_type OWNER TO laze;

--
-- Name: dim_content_type_content_type_dim_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.dim_content_type_content_type_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dim_content_type_content_type_dim_id_seq OWNER TO laze;

--
-- Name: dim_content_type_content_type_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.dim_content_type_content_type_dim_id_seq OWNED BY public.dim_content_type.content_type_dim_id;


--
-- Name: dim_date; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_date (
    date_dim_id bigint NOT NULL,
    date_actual date NOT NULL,
    day_suffix character varying(4) NOT NULL,
    day_name character varying(9) NOT NULL,
    day_of_week integer NOT NULL,
    day_of_month integer NOT NULL,
    day_of_quarter integer NOT NULL,
    day_of_year integer NOT NULL,
    week_of_month integer NOT NULL,
    week_of_year integer NOT NULL,
    week_of_year_iso character(10) NOT NULL,
    month_actual integer NOT NULL,
    month_name character varying(9) NOT NULL,
    month_name_abbreviated character(3) NOT NULL,
    quarter_actual integer NOT NULL,
    quarter_name character varying(9) NOT NULL,
    year_actual integer NOT NULL,
    first_day_of_week date NOT NULL,
    last_day_of_week date NOT NULL,
    first_day_of_month date NOT NULL,
    last_day_of_month date NOT NULL,
    first_day_of_quarter date NOT NULL,
    last_day_of_quarter date NOT NULL,
    first_day_of_year date NOT NULL,
    last_day_of_year date NOT NULL,
    mmyyyy character(6) NOT NULL,
    mmddyyyy character(10) NOT NULL,
    weekend_indr boolean NOT NULL
);


ALTER TABLE public.dim_date OWNER TO laze;

--
-- Name: dim_hierarchy_codes; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_hierarchy_codes (
    hierarchy_codes_dim_id integer NOT NULL,
    type text NOT NULL
);


ALTER TABLE public.dim_hierarchy_codes OWNER TO laze;

--
-- Name: dim_hierarchy_codes_hierarchy_codes_dim_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.dim_hierarchy_codes_hierarchy_codes_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dim_hierarchy_codes_hierarchy_codes_dim_id_seq OWNER TO laze;

--
-- Name: dim_hierarchy_codes_hierarchy_codes_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.dim_hierarchy_codes_hierarchy_codes_dim_id_seq OWNED BY public.dim_hierarchy_codes.hierarchy_codes_dim_id;


--
-- Name: dim_method; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_method (
    method_dim_id integer NOT NULL,
    type character varying(9) NOT NULL
);


ALTER TABLE public.dim_method OWNER TO laze;

--
-- Name: dim_method_method_dim_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.dim_method_method_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dim_method_method_dim_id_seq OWNER TO laze;

--
-- Name: dim_method_method_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.dim_method_method_dim_id_seq OWNED BY public.dim_method.method_dim_id;


--
-- Name: dim_result_codes; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_result_codes (
    result_codes_dim_id integer NOT NULL,
    type text NOT NULL
);


ALTER TABLE public.dim_result_codes OWNER TO laze;

--
-- Name: dim_result_codes_result_codes_dim_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.dim_result_codes_result_codes_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dim_result_codes_result_codes_dim_id_seq OWNER TO laze;

--
-- Name: dim_result_codes_result_codes_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.dim_result_codes_result_codes_dim_id_seq OWNED BY public.dim_result_codes.result_codes_dim_id;


--
-- Name: dim_time; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_time (
    time_dim_id integer NOT NULL,
    time_type time without time zone,
    time_value character(5) NOT NULL,
    hours_24 character(2) NOT NULL,
    hours_12 character(2) NOT NULL,
    hour_minutes character(2) NOT NULL,
    day_minutes integer NOT NULL,
    day_time_name character varying(20) NOT NULL,
    day_night character varying(20) NOT NULL
);


ALTER TABLE public.dim_time OWNER TO laze;

--
-- Name: dim_url; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_url (
    url_dim_id integer NOT NULL,
    url_netloc character varying(128) NOT NULL
);


ALTER TABLE public.dim_url OWNER TO laze;

--
-- Name: dim_url_url_dim_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.dim_url_url_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dim_url_url_dim_id_seq OWNER TO laze;

--
-- Name: dim_url_url_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.dim_url_url_dim_id_seq OWNED BY public.dim_url.url_dim_id;


--
-- Name: dim_user; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.dim_user (
    user_dim_id integer NOT NULL,
    type character varying(40) NOT NULL
);


ALTER TABLE public.dim_user OWNER TO laze;

--
-- Name: dim_user_user_dim_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.dim_user_user_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dim_user_user_dim_id_seq OWNER TO laze;

--
-- Name: dim_user_user_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.dim_user_user_dim_id_seq OWNED BY public.dim_user.user_dim_id;


--
-- Name: fact_request; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.fact_request (
    fact_id bigint NOT NULL,
    date_id bigint NOT NULL,
    time_id integer NOT NULL,
    content_type_id integer NOT NULL,
    user_id integer NOT NULL,
    hierarchy_codes_id integer NOT NULL,
    url_id integer NOT NULL,
    result_codes_id integer NOT NULL,
    method_id integer NOT NULL,
    client_id integer NOT NULL,
    duration integer NOT NULL,
    bytes integer NOT NULL,
    url_scheme character varying(10),
    url_path text,
    url_params text
);


ALTER TABLE public.fact_request OWNER TO laze;

--
-- Name: fact_request_fact_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.fact_request_fact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fact_request_fact_id_seq OWNER TO laze;

--
-- Name: fact_request_fact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.fact_request_fact_id_seq OWNED BY public.fact_request.fact_id;


--
-- Name: files; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.files (
    id integer NOT NULL,
    uploaded_time timestamp without time zone NOT NULL,
    file_name character varying(150) NOT NULL,
    uploaded_file bytea NOT NULL
);


ALTER TABLE public.files OWNER TO laze;

--
-- Name: files_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_id_seq OWNER TO laze;

--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.files_id_seq OWNED BY public.files.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: laze
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(64) NOT NULL,
    name character varying(32) NOT NULL,
    lastname character varying(32) NOT NULL,
    cpf character varying(11) NOT NULL,
    email character varying(120) NOT NULL,
    phone character varying(11) NOT NULL,
    password character varying(128) NOT NULL
);


ALTER TABLE public.users OWNER TO laze;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: laze
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO laze;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: laze
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vw_content_types; Type: MATERIALIZED VIEW; Schema: public; Owner: laze
--

CREATE MATERIALIZED VIEW public.vw_content_types AS
 SELECT dd.year_actual AS year,
    dd.month_actual AS month,
    dct.type AS mime,
    count(fr.content_type_id) AS total
   FROM ((public.dim_date dd
     JOIN public.fact_request fr ON ((fr.date_id = dd.date_dim_id)))
     JOIN public.dim_content_type dct ON ((fr.content_type_id = dct.content_type_dim_id)))
  GROUP BY dd.year_actual, dd.month_actual, dct.type
  ORDER BY dd.year_actual, dd.month_actual, (count(fr.content_type_id)) DESC
  WITH NO DATA;


ALTER TABLE public.vw_content_types OWNER TO laze;

--
-- Name: vw_result_codes; Type: MATERIALIZED VIEW; Schema: public; Owner: laze
--

CREATE MATERIALIZED VIEW public.vw_result_codes AS
 SELECT dd.year_actual AS year,
    dd.month_actual AS month,
    drc.type AS result,
    count(fr.result_codes_id) AS total
   FROM ((public.dim_date dd
     JOIN public.fact_request fr ON ((fr.date_id = dd.date_dim_id)))
     JOIN public.dim_result_codes drc ON ((fr.result_codes_id = drc.result_codes_dim_id)))
  GROUP BY dd.year_actual, dd.month_actual, drc.type
  ORDER BY dd.year_actual, dd.month_actual, (count(fr.result_codes_id)) DESC
  WITH NO DATA;


ALTER TABLE public.vw_result_codes OWNER TO laze;

--
-- Name: dim_client client_dim_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_client ALTER COLUMN client_dim_id SET DEFAULT nextval('public.dim_client_client_dim_id_seq'::regclass);


--
-- Name: dim_content_type content_type_dim_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_content_type ALTER COLUMN content_type_dim_id SET DEFAULT nextval('public.dim_content_type_content_type_dim_id_seq'::regclass);


--
-- Name: dim_hierarchy_codes hierarchy_codes_dim_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_hierarchy_codes ALTER COLUMN hierarchy_codes_dim_id SET DEFAULT nextval('public.dim_hierarchy_codes_hierarchy_codes_dim_id_seq'::regclass);


--
-- Name: dim_method method_dim_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_method ALTER COLUMN method_dim_id SET DEFAULT nextval('public.dim_method_method_dim_id_seq'::regclass);


--
-- Name: dim_result_codes result_codes_dim_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_result_codes ALTER COLUMN result_codes_dim_id SET DEFAULT nextval('public.dim_result_codes_result_codes_dim_id_seq'::regclass);


--
-- Name: dim_url url_dim_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_url ALTER COLUMN url_dim_id SET DEFAULT nextval('public.dim_url_url_dim_id_seq'::regclass);


--
-- Name: dim_user user_dim_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_user ALTER COLUMN user_dim_id SET DEFAULT nextval('public.dim_user_user_dim_id_seq'::regclass);


--
-- Name: fact_request fact_id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request ALTER COLUMN fact_id SET DEFAULT nextval('public.fact_request_fact_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.files ALTER COLUMN id SET DEFAULT nextval('public.files_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: dim_client; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_client (client_dim_id, client_address) FROM stdin;
\.


--
-- Data for Name: dim_content_type; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_content_type (content_type_dim_id, type) FROM stdin;
\.


--
-- Data for Name: dim_date; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_date (date_dim_id, date_actual, day_suffix, day_name, day_of_week, day_of_month, day_of_quarter, day_of_year, week_of_month, week_of_year, week_of_year_iso, month_actual, month_name, month_name_abbreviated, quarter_actual, quarter_name, year_actual, first_day_of_week, last_day_of_week, first_day_of_month, last_day_of_month, first_day_of_quarter, last_day_of_quarter, first_day_of_year, last_day_of_year, mmyyyy, mmddyyyy, weekend_indr) FROM stdin;
\.


--
-- Data for Name: dim_hierarchy_codes; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_hierarchy_codes (hierarchy_codes_dim_id, type) FROM stdin;
\.


--
-- Data for Name: dim_method; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_method (method_dim_id, type) FROM stdin;
\.


--
-- Data for Name: dim_result_codes; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_result_codes (result_codes_dim_id, type) FROM stdin;
\.


--
-- Data for Name: dim_time; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_time (time_dim_id, time_type, time_value, hours_24, hours_12, hour_minutes, day_minutes, day_time_name, day_night) FROM stdin;
\.


--
-- Data for Name: dim_url; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_url (url_dim_id, url_netloc) FROM stdin;
\.


--
-- Data for Name: dim_user; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.dim_user (user_dim_id, type) FROM stdin;
\.


--
-- Data for Name: fact_request; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.fact_request (fact_id, date_id, time_id, content_type_id, user_id, hierarchy_codes_id, url_id, result_codes_id, method_id, client_id, duration, bytes, url_scheme, url_path, url_params) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.files (id, uploaded_time, file_name, uploaded_file) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: laze
--

COPY public.users (id, username, name, lastname, cpf, email, phone, password) FROM stdin;
1	natt	Natalia	Knob	01330694007	nattgomesadv@gmail.com	54999596950	pbkdf2:sha256:50000$zBq5wX3a$99b902e33a14eb5df228f1abd1d8211b6727bcf5312dd8da02d4256c8f0248aa
\.


--
-- Name: dim_client_client_dim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.dim_client_client_dim_id_seq', 838, true);


--
-- Name: dim_content_type_content_type_dim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.dim_content_type_content_type_dim_id_seq', 369, true);


--
-- Name: dim_hierarchy_codes_hierarchy_codes_dim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.dim_hierarchy_codes_hierarchy_codes_dim_id_seq', 14667, true);


--
-- Name: dim_method_method_dim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.dim_method_method_dim_id_seq', 29, true);


--
-- Name: dim_result_codes_result_codes_dim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.dim_result_codes_result_codes_dim_id_seq', 253, true);


--
-- Name: dim_url_url_dim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.dim_url_url_dim_id_seq', 18911, true);


--
-- Name: dim_user_user_dim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.dim_user_user_dim_id_seq', 461, true);


--
-- Name: fact_request_fact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.fact_request_fact_id_seq', 3455707, true);


--
-- Name: files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.files_id_seq', 8, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: laze
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: dim_client dim_client_client_address_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_client
    ADD CONSTRAINT dim_client_client_address_key UNIQUE (client_address);


--
-- Name: dim_client dim_client_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_client
    ADD CONSTRAINT dim_client_pkey PRIMARY KEY (client_dim_id);


--
-- Name: dim_content_type dim_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_content_type
    ADD CONSTRAINT dim_content_type_pkey PRIMARY KEY (content_type_dim_id);


--
-- Name: dim_content_type dim_content_type_type_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_content_type
    ADD CONSTRAINT dim_content_type_type_key UNIQUE (type);


--
-- Name: dim_date dim_date_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_date
    ADD CONSTRAINT dim_date_pkey PRIMARY KEY (date_dim_id);


--
-- Name: dim_hierarchy_codes dim_hierarchy_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_hierarchy_codes
    ADD CONSTRAINT dim_hierarchy_codes_pkey PRIMARY KEY (hierarchy_codes_dim_id);


--
-- Name: dim_hierarchy_codes dim_hierarchy_codes_type_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_hierarchy_codes
    ADD CONSTRAINT dim_hierarchy_codes_type_key UNIQUE (type);


--
-- Name: dim_method dim_method_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_method
    ADD CONSTRAINT dim_method_pkey PRIMARY KEY (method_dim_id);


--
-- Name: dim_method dim_method_type_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_method
    ADD CONSTRAINT dim_method_type_key UNIQUE (type);


--
-- Name: dim_result_codes dim_result_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_result_codes
    ADD CONSTRAINT dim_result_codes_pkey PRIMARY KEY (result_codes_dim_id);


--
-- Name: dim_result_codes dim_result_codes_type_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_result_codes
    ADD CONSTRAINT dim_result_codes_type_key UNIQUE (type);


--
-- Name: dim_time dim_time_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_time
    ADD CONSTRAINT dim_time_pkey PRIMARY KEY (time_dim_id);


--
-- Name: dim_url dim_url_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_url
    ADD CONSTRAINT dim_url_pkey PRIMARY KEY (url_dim_id);


--
-- Name: dim_url dim_url_url_netloc_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_url
    ADD CONSTRAINT dim_url_url_netloc_key UNIQUE (url_netloc);


--
-- Name: dim_user dim_user_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_user
    ADD CONSTRAINT dim_user_pkey PRIMARY KEY (user_dim_id);


--
-- Name: dim_user dim_user_type_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.dim_user
    ADD CONSTRAINT dim_user_type_key UNIQUE (type);


--
-- Name: fact_request fact_request_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_pkey PRIMARY KEY (fact_id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: users users_cpf_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_cpf_key UNIQUE (cpf);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: fact_request_client_id_idx; Type: INDEX; Schema: public; Owner: laze
--

CREATE INDEX fact_request_client_id_idx ON public.fact_request USING btree (client_id);


--
-- Name: fact_request_client_id_idx1; Type: INDEX; Schema: public; Owner: laze
--

CREATE INDEX fact_request_client_id_idx1 ON public.fact_request USING btree (client_id);


--
-- Name: fact_request_date_id_idx; Type: INDEX; Schema: public; Owner: laze
--

CREATE INDEX fact_request_date_id_idx ON public.fact_request USING btree (date_id);


--
-- Name: vw_content_types_year_month_mime_idx; Type: INDEX; Schema: public; Owner: laze
--

CREATE UNIQUE INDEX vw_content_types_year_month_mime_idx ON public.vw_content_types USING btree (year, month, mime);


--
-- Name: vw_result_codes_year_month_result_idx; Type: INDEX; Schema: public; Owner: laze
--

CREATE UNIQUE INDEX vw_result_codes_year_month_result_idx ON public.vw_result_codes USING btree (year, month, result);


--
-- Name: files refresh_views; Type: TRIGGER; Schema: public; Owner: laze
--

CREATE TRIGGER refresh_views AFTER INSERT OR TRUNCATE ON public.files FOR EACH STATEMENT EXECUTE PROCEDURE public.p_refresh_views();


--
-- Name: fact_request fact_request_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.dim_client(client_dim_id);


--
-- Name: fact_request fact_request_content_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_content_type_id_fkey FOREIGN KEY (content_type_id) REFERENCES public.dim_content_type(content_type_dim_id);


--
-- Name: fact_request fact_request_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dim_date(date_dim_id);


--
-- Name: fact_request fact_request_hierarchy_codes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_hierarchy_codes_id_fkey FOREIGN KEY (hierarchy_codes_id) REFERENCES public.dim_hierarchy_codes(hierarchy_codes_dim_id);


--
-- Name: fact_request fact_request_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.dim_method(method_dim_id);


--
-- Name: fact_request fact_request_result_codes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_result_codes_id_fkey FOREIGN KEY (result_codes_id) REFERENCES public.dim_result_codes(result_codes_dim_id);


--
-- Name: fact_request fact_request_time_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_time_id_fkey FOREIGN KEY (time_id) REFERENCES public.dim_time(time_dim_id);


--
-- Name: fact_request fact_request_url_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_url_id_fkey FOREIGN KEY (url_id) REFERENCES public.dim_url(url_dim_id);


--
-- Name: fact_request fact_request_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: laze
--

ALTER TABLE ONLY public.fact_request
    ADD CONSTRAINT fact_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.dim_user(user_dim_id);


--
-- Name: vw_content_types; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: laze
--

REFRESH MATERIALIZED VIEW public.vw_content_types;


--
-- Name: vw_result_codes; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: laze
--

REFRESH MATERIALIZED VIEW public.vw_result_codes;


--
-- PostgreSQL database dump complete
--
