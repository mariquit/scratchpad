
DROP TABLE IF EXISTS ec2;

CREATE TABLE ec2 AS
SELECT
  linkedaccountid, resourceid AS instance_id
, split_part( usagetype,'BoxUsage:',2 ) AS instance_type
, trim(CASE reservedinstance
    WHEN 'Y'
    THEN TRIM( TRAILING ', ' FROM split_part( split_part( split_part(itemdescription, ', ', 1),'per ',2 ),split_part( usagetype,'BoxUsage:',2 ),1 ) )
    ELSE split_part( split_part( split_part(itemdescription, ', ', 1),'Demand ',2 ),split_part( usagetype,'BoxUsage:',2 ),1 )
END) AS platform
, availabilityzone
, SUBSTRING(availabilityzone,1,POSITION('-' IN SUBSTRING(availabilityzone,4,LENGTH(availabilityzone)))+4) AS region_short
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
WHERE productname ILIKE '%compute cloud%'
AND usagetype ILIKE '%boxusage%'
AND operation ILIKE '%runinstance%'
AND recordtype = 'LineItem'
AND itemdescription NOT ILIKE '%subscription%'
AND itemdescription NOT ILIKE '%recurring fee%'
UNION
SELECT
  linkedaccountid, resourceid AS instance_id
, split_part( usagetype,'BoxUsage:',2 ) AS instance_type
, trim(CASE reservedinstance
    WHEN 'Y'
    THEN TRIM( TRAILING ', ' FROM split_part( split_part( split_part(itemdescription, ', ', 1),'per ',2 ),split_part( usagetype,'BoxUsage:',2 ),1 ) )
    ELSE split_part( split_part( split_part(itemdescription, ', ', 1),'Demand ',2 ),split_part( usagetype,'BoxUsage:',2 ),1 )
END) AS platform
, availabilityzone
, SUBSTRING(availabilityzone,1,POSITION('-' IN SUBSTRING(availabilityzone,4,LENGTH(availabilityzone)))+4) AS region_short
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
WHERE productname ILIKE '%compute cloud%'
AND usagetype ILIKE '%boxusage%'
AND operation ILIKE '%runinstance%'
AND recordtype = 'LineItem'
AND itemdescription NOT ILIKE '%subscription%'
AND itemdescription NOT ILIKE '%recurring fee%'
UNION
SELECT
  linkedaccountid, resourceid AS instance_id
, split_part( usagetype,'BoxUsage:',2 ) AS instance_type
, trim(CASE reservedinstance
    WHEN 'Y'
    THEN TRIM( TRAILING ', ' FROM split_part( split_part( split_part(itemdescription, ', ', 1),'per ',2 ),split_part( usagetype,'BoxUsage:',2 ),1 ) )
    ELSE split_part( split_part( split_part(itemdescription, ', ', 1),'Demand ',2 ),split_part( usagetype,'BoxUsage:',2 ),1 )
END) AS platform
, availabilityzone
, SUBSTRING(availabilityzone,1,POSITION('-' IN SUBSTRING(availabilityzone,4,LENGTH(availabilityzone)))+4) AS region_short
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
WHERE productname ILIKE '%compute cloud%'
AND usagetype ILIKE '%boxusage%'
AND operation ILIKE '%runinstance%'
AND recordtype = 'LineItem'
AND itemdescription NOT ILIKE '%subscription%'
AND itemdescription NOT ILIKE '%recurring fee%'
;


DROP TABLE IF EXISTS ec2_usage;

CREATE TABLE ec2_usage
AS
SELECT linkedaccountid, instance_id, a.yearmon, reservedinstance, availabilityzone, region_short, instance_type, platform
, sum(unblendedcost)::FLOAT(8) AS usagecosts
, sum(hours) AS usagehours
--, max(hours_in_month) AS hours_in_month
, (sum(hours) / max(hours_in_month) * 100)::FLOAT(8) AS usagepct
, weight
FROM ec2 a, lookup_days b
WHERE a.yearmon = b.yearmon
GROUP BY linkedaccountid, instance_id, a.yearmon, reservedinstance, availabilityzone, region_short, instance_type, platform, weight
ORDER BY linkedaccountid, instance_id, a.yearmon DESC;
