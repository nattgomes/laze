CREATE MATERIALIZED VIEW vw_result_codes AS
select dd.year_actual as year, dd.month_actual as month, drc.type as result, count(fr.result_codes_id) as total
from dim_date dd
       join fact_request fr on fr.date_id = dd.date_dim_id
       join dim_result_codes drc on fr.result_codes_id = drc.result_codes_dim_id
group by 1, 2, 3
order by 1, 2, 4 desc
  WITH DATA;

DROP MATERIALIZED VIEW vw_result_codes;

REFRESH MATERIALIZED VIEW CONCURRENTLY vw_result_codes;
CREATE UNIQUE INDEX ON vw_result_codes (year, month, result);



--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__
--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__


CREATE MATERIALIZED VIEW vw_content_types AS
select dd.year_actual as year, dd.month_actual as month, dct.type as mime, count(fr.content_type_id) as total
from dim_date dd
       join fact_request fr on fr.date_id = dd.date_dim_id
       join dim_content_type dct on fr.content_type_id = dct.content_type_dim_id
group by 1, 2, 3
order by 1, 2, 4 desc
  WITH DATA;

  CREATE UNIQUE INDEX ON vw_content_types (year, month, mime);
