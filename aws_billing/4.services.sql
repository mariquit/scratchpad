DROP TABLE IF EXISTS services;

CREATE TABLE services
AS
SELECT
  productname, to_char(min(usagestartdate),'yyyymm') AS yearmon
, count( DISTINCT resourceid ) AS resource_count
, count( DISTINCT availabilityzone ) AS az_count
, sum( unblendedcost )::DECIMAL(10,2) AS costs
FROM dbr201707
WHERE recordtype = 'LineItem'
AND operation IS NOT NULL
GROUP BY productname
UNION
SELECT
  productname, to_char(min(usagestartdate),'yyyymm') AS yearmon
, count( DISTINCT resourceid ) AS resource_count
, count( DISTINCT availabilityzone ) AS az_count
, sum( unblendedcost )::DECIMAL(10,2) AS costs
FROM dbr201708
WHERE recordtype = 'LineItem'
AND operation IS NOT NULL
GROUP BY productname
UNION
SELECT
  productname, to_char(min(usagestartdate),'yyyymm') AS yearmon
, count( DISTINCT resourceid ) AS resource_count
, count( DISTINCT availabilityzone ) AS az_count
, sum( unblendedcost )::DECIMAL(10,2) AS costs
FROM dbr201709
WHERE recordtype = 'LineItem'
AND operation IS NOT NULL
GROUP BY productname
ORDER BY yearmon DESC, costs DESC, productname ASC
;


DROP TABLE IF EXISTS report_services;

CREATE TABLE report_services
AS
SELECT productname
, sum(rescnt1) AS resource_count_month1
, sum(rescnt2) AS resource_count_month2
, sum(rescnt3) AS resource_count_month3
, sum(azcnt1) AS AZ_count_month1
, sum(azcnt2) AS AZ_count_month2
, sum(azcnt3) AS AZ_count_month3
, sum(costs1) AS costs_month1
, sum(costs2) AS costs_month2
, sum(costs3) AS costs_month3
FROM (
    SELECT productname
    , CASE yearmon WHEN '201707' THEN resource_count ELSE 0 END AS rescnt1
    , CASE yearmon WHEN '201708' THEN resource_count ELSE 0 END AS rescnt2
    , CASE yearmon WHEN '201709' THEN resource_count ELSE 0 END AS rescnt3
    , CASE yearmon WHEN '201707' THEN az_count ELSE 0 END AS azcnt1
    , CASE yearmon WHEN '201708' THEN az_count ELSE 0 END AS azcnt2
    , CASE yearmon WHEN '201709' THEN az_count ELSE 0 END AS azcnt3
    , CASE yearmon WHEN '201707' THEN costs ELSE 0 END AS costs1
    , CASE yearmon WHEN '201708' THEN costs ELSE 0 END AS costs2
    , CASE yearmon WHEN '201709' THEN costs ELSE 0 END AS costs3
    FROM services
) AS A
GROUP BY productname
ORDER BY costs_month3 DESC, productname ASC;

-- SELECT * FROM report_services limit 5;
