DROP TABLE IF EXISTS rds;

CREATE TABLE rds
AS
SELECT
  linkedaccountid, split_part(resourceid, 'db:', 2) AS instance_id
  , split_part( usagetype,'Usage:',2 ) AS instance_type
  , split_part( split_part( itemdescription,'running ',2 ),split_part( usagetype,'Usage:',2 ),1 ) AS platform
  , availabilityzone
  , reservedinstance
  , unblendedcost
  , usagequantity
  , date_part('hour',usageenddate-usagestartdate)::INTEGER AS hours
  , tag_name
  --, tag_customer
  --, tag_env
  --, tag_pro
  --, aws_cfn_stack_name
  , to_char(usagestartdate, 'yyyymm') AS yearmon
  , usagestartdate
  , usageenddate
  , '1'::INTEGER AS weight
FROM dbr201707
WHERE productname ILIKE '%rds service%'
AND operation ILIKE '%createdbinstance%'
AND usagetype ILIKE '%instanceusage%'
AND recordtype = 'LineItem'
AND itemdescription ILIKE '%running%'
UNION
SELECT
  linkedaccountid, split_part(resourceid, 'db:', 2) AS instance_id
  , split_part( usagetype,'Usage:',2 ) AS instance_type
  , split_part( split_part( itemdescription,'running ',2 ),split_part( usagetype,'Usage:',2 ),1 ) AS platform
  , availabilityzone
  , reservedinstance
  , unblendedcost
  , usagequantity
  , date_part('hour',usageenddate-usagestartdate)::INTEGER AS hours
  , tag_name
  --, tag_customer
  --, tag_env
  --, tag_pro
  --, aws_cfn_stack_name
  , to_char(usagestartdate, 'yyyymm') AS yearmon
  , usagestartdate
  , usageenddate
  , '2'::INTEGER AS weight
FROM dbr201708
WHERE productname ILIKE '%rds service%'
AND operation ILIKE '%createdbinstance%'
AND usagetype ILIKE '%instanceusage%'
AND recordtype = 'LineItem'
AND itemdescription ILIKE '%running%'
UNION
SELECT
  linkedaccountid, split_part(resourceid, 'db:', 2) AS instance_id
  , split_part( usagetype,'Usage:',2 ) AS instance_type
  , split_part( split_part( itemdescription,'running ',2 ),split_part( usagetype,'Usage:',2 ),1 ) AS platform
  , availabilityzone
  , reservedinstance
  , unblendedcost
  , usagequantity
  , date_part('hour',usageenddate-usagestartdate)::INTEGER AS hours
  , tag_name
  --, tag_customer
  --, tag_env
  --, tag_pro
  --, aws_cfn_stack_name
  , to_char(usagestartdate, 'yyyymm') AS yearmon
  , usagestartdate
  , usageenddate
  , '4'::INTEGER AS weight
FROM dbr201709
WHERE productname ILIKE '%relational database%'
AND operation ILIKE '%createdbinstance%'
AND usagetype ILIKE '%instanceusage%'
AND recordtype = 'LineItem'
AND itemdescription ILIKE '%running%'
;


DROP TABLE IF EXISTS rds_usage;

CREATE TABLE rds_usage
AS
SELECT linkedaccountid, instance_id, a.yearmon
, reservedinstance, availabilityzone, instance_type, platform
, sum(unblendedcost)::FLOAT(8) AS usagecosts
, sum(hours) AS usagehours
--, max(hours_in_month) as hours_in_month
, (sum(hours) / max(hours_in_month) * 100)::float(8) AS usagepct
, weight
FROM rds a, lookup_days b
WHERE a.yearmon = b.yearmon
GROUP BY linkedaccountid, instance_id, a.yearmon
, reservedinstance, availabilityzone,  instance_type
, platform, weight
ORDER BY linkedaccountid, instance_id, a.yearmon DESC;

/*
SELECT DISTINCT itemdescription
FROM dbr201707
WHERE productname ILIKE '%rds service%'
AND operation ILIKE '%createdbinstance%'
AND usagetype ILIKE '%instanceusage%';
*/
