--------------------------
-- DROP TABLES
drop table dim_user, dim_time, dim_date, dim_url, dim_hierarchy_codes, dim_method, dim_result_codes,
  dim_client, dim_content_type, fact_request cascade;


--------------------------
-- CREATE TABLES
begin;
CREATE TABLE users(
  id                       SERIAL NOT NULL PRIMARY KEY,
  username                 VARCHAR(64) NOT NULL UNIQUE,
  name                     VARCHAR(32) NOT NULL,
  lastname                 VARCHAR(32) NOT NULL,
  cpf                      VARCHAR(11) NOT NULL UNIQUE,
  email                    VARCHAR(120) NOT NULL UNIQUE,
  phone                    VARCHAR(11) NOT NULL,
  password                 VARCHAR(128) NOT NULL
);

CREATE TABLE dim_client
(
  client_dim_id  SERIAL      NOT NULL PRIMARY KEY,
  client_address VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE dim_method
(
  method_dim_id SERIAL     NOT NULL PRIMARY KEY,
  type          VARCHAR(9) NOT NULL UNIQUE
);

CREATE TABLE dim_result_codes
(
  result_codes_dim_id SERIAL      NOT NULL PRIMARY KEY,
  type                TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_url
(
  url_dim_id SERIAL       NOT NULL PRIMARY KEY,
  url_netloc VARCHAR(128) NOT NULL UNIQUE
);

CREATE TABLE dim_hierarchy_codes
(
  hierarchy_codes_dim_id SERIAL      NOT NULL PRIMARY KEY,
  type                   TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_user
(
  user_dim_id SERIAL      NOT NULL PRIMARY KEY,
  type        VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE dim_content_type
(
  content_type_dim_id SERIAL      NOT NULL PRIMARY KEY,
  type                TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_time
(
  time_dim_id   INTEGER     NOT NULL PRIMARY KEY,
  time_type     TIME,
  time_value    CHAR(5)     NOT NULL,
  hours_24      CHAR(2)     NOT NULL,
  hours_12      CHAR(2)     NOT NULL,
  hour_minutes  CHAR(2)     NOT NULL,
  day_minutes   INTEGER     NOT NULL,
  day_time_name VARCHAR(20) NOT NULL,
  day_night     VARCHAR(20) NOT NULL
);


CREATE TABLE dim_date
(
  date_dim_id            BIGINT    NOT NULL PRIMARY KEY,
  date_actual            DATE       NOT NULL,
  day_suffix             VARCHAR(4) NOT NULL,
  day_name               VARCHAR(9) NOT NULL,
  day_of_week            INTEGER    NOT NULL,
  day_of_month           INTEGER    NOT NULL,
  day_of_quarter         INTEGER    NOT NULL,
  day_of_year            INTEGER    NOT NULL,
  week_of_month          INTEGER    NOT NULL,
  week_of_year           INTEGER    NOT NULL,
  week_of_year_iso       CHAR(10)   NOT NULL,
  month_actual           INTEGER    NOT NULL,
  month_name             VARCHAR(9) NOT NULL,
  month_name_abbreviated CHAR(3)    NOT NULL,
  quarter_actual         INTEGER    NOT NULL,
  quarter_name           VARCHAR(9) NOT NULL,
  year_actual            INTEGER    NOT NULL,
  first_day_of_week      DATE       NOT NULL,
  last_day_of_week       DATE       NOT NULL,
  first_day_of_month     DATE       NOT NULL,
  last_day_of_month      DATE       NOT NULL,
  first_day_of_quarter   DATE       NOT NULL,
  last_day_of_quarter    DATE       NOT NULL,
  first_day_of_year      DATE       NOT NULL,
  last_day_of_year       DATE       NOT NULL,
  mmyyyy                 CHAR(6)    NOT NULL,
  mmddyyyy               CHAR(10)   NOT NULL,
  weekend_indr           BOOLEAN    NOT NULL
);


CREATE TABLE fact_request
(
  fact_id            BIGSERIAL NOT NULL PRIMARY KEY,
  date_id            BIGINT NOT NULL,
  time_id            INTEGER NOT NULL,
  content_type_id    INTEGER NOT NULL,
  user_id            INTEGER NOT NULL,
  hierarchy_codes_id INTEGER NOT NULL,
  url_id             INTEGER NOT NULL,
  result_codes_id    INTEGER NOT NULL,
  method_id          INTEGER NOT NULL,
  client_id          INTEGER NOT NULL,
  duration           INTEGER NOT NULL,
  bytes              INTEGER NOT NULL,
  url_scheme         VARCHAR(10),
  url_path           TEXT,
  url_params         TEXT,
  FOREIGN KEY (date_id) REFERENCES dim_date,
  FOREIGN KEY (time_id) REFERENCES dim_time,
  FOREIGN KEY (content_type_id) REFERENCES dim_content_type,
  FOREIGN KEY (user_id) REFERENCES dim_user,
  FOREIGN KEY (hierarchy_codes_id) REFERENCES dim_hierarchy_codes,
  FOREIGN KEY (url_id) REFERENCES dim_url,
  FOREIGN KEY (result_codes_id) REFERENCES dim_result_codes,
  FOREIGN KEY (method_id) REFERENCES dim_method,
  FOREIGN KEY (client_id) REFERENCES dim_client
);

CREATE TABLE files
(
  id            SERIAL       NOT NULL PRIMARY KEY,
  uploaded_time TIMESTAMP    NOT NULL,
  file_name     VARCHAR(150) NOT NULL,
  uploaded_file BYTEA        NOT NULL
);

  commit;



-- http://www.comfsm.fm/computing/squid/FAQ.html#toc6
-- http://www.comfsm.fm/computing/squid/FAQ-6.html

  -- https://medium.com/@duffn/creating-a-date-dimension-table-in-postgresql-af3f8e2941ac

  -- https://www.postgresql.org/message-id/CAE+TzGq0yFrHrLwMnD6CdVD2mfuANjBToRn9SJeWai8zyZMxrw@mail.gmail.com

  -- https://gist.github.com/jpotts18/eaaf18c2b2ffe969f9641c2e05783150

  -- https://gist.github.com/jpotts18/36e4f6d469fb9b66d94059f9d3e07497
