
DROP TABLE IF EXISTS raw_pricing_ec2;

CREATE TABLE raw_pricing_ec2
( sku VARCHAR( 18 )
, termcode VARCHAR( 12 )
, termtype VARCHAR( 8 )
, description VARCHAR( 247 )
, effectdate date
, unit VARCHAR( 8 )
, price FLOAT(8)
, purchase_option VARCHAR( 15 )
, region_name VARCHAR( 24 )
, instance_type VARCHAR( 12 )
, current_gen VARCHAR( 3 )
, tenancy VARCHAR( 10 )
, platform VARCHAR( 7 )
, licensing VARCHAR( 22 )
, sriov VARCHAR( 3 )
, preinst_app VARCHAR( 20 )
);

COPY raw_pricing_ec2
FROM '/tmp/ec2.csv'
DELIMITER '|'
NULL AS ''
CSV HEADER;


UPDATE raw_pricing_ec2 SET purchase_option = 'On-Demand' WHERE purchase_option IS NULL AND termtype = 'OnDemand';


DROP TABLE IF EXISTS lookup_sku_ec2;

CREATE TABLE lookup_sku_ec2 AS
SELECT DISTINCT region_name, platform, instance_type, sku, description, current_gen, licensing, COALESCE(sriov,'No') AS opt_sriov, preinst_app
FROM raw_pricing_ec2
WHERE (sku, effectdate) IN (
    SELECT sku, max(effectdate) AS effectdate
    FROM raw_pricing_ec2
    WHERE unit = 'Hrs'
    AND tenancy NOT IN ('Host', 'Dedicated')
    GROUP BY sku
)
AND description NOT IN ('Upfront Fee')
ORDER BY platform, instance_type, sku, description
;

CREATE UNIQUE INDEX idx_lookup_sku_ec2 ON lookup_sku_ec2(sku);

/*
select * from lookup_sku_ec2
--where sku in ('223BX6UNNB3JE9ET','22NNFPH4XF5VJ6K9','23YH2UEV4EQ6TYRD')
where sku ilike 'zy733qb%'
order by instance_type, sku;
*/


DROP TABLE IF EXISTS pricing_ec2;

CREATE TABLE pricing_ec2 AS
SELECT a.sku, a.region_name, a.instance_type, a.platform, b.description--, current_gen, description
, sum(on_demand_rph) AS on_demand_rph
, sum(no_upfront_rph) AS no_upfront_rph
, 0 as no_upfront_ot
, sum(partial_upfront_rph) AS partial_upfront_rph
, sum(partial_upfront_ot) AS partial_upfront_ot
, sum(all_upfront_rph) AS all_upfront_rph
, sum(all_upfront_ot) AS all_upfront_ot
FROM (
    SELECT sku, termcode, region_name, instance_type, platform
    , CASE termtype WHEN 'OnDemand' THEN price ELSE 0 END AS on_demand_rph
    , CASE purchase_option WHEN 'No Upfront' THEN CASE unit WHEN 'Hrs' THEN price ELSE 0 END ELSE 0 END AS no_upfront_rph
    , CASE purchase_option WHEN 'Partial Upfront' THEN CASE unit WHEN 'Hrs' THEN price ELSE 0 END ELSE 0 END AS partial_upfront_rph
    , CASE purchase_option WHEN 'Partial Upfront' THEN CASE unit WHEN 'Quantity' THEN price ELSE 0 END ELSE 0 END AS partial_upfront_ot
    , CASE purchase_option WHEN 'All Upfront' THEN CASE unit WHEN 'Hrs' THEN price ELSE 0 END ELSE 0 END AS all_upfront_rph
    , CASE purchase_option WHEN 'All Upfront' THEN CASE unit WHEN 'Quantity' THEN price ELSE 0 END ELSE 0 END AS all_upfront_ot
    , unit
    FROM raw_pricing_ec2
    WHERE tenancy NOT IN ('Host', 'Dedicated')
    --order by region_name, instance_type, platform, sku, termcode
) AS a, lookup_sku_ec2 b
WHERE a.sku = b.sku
GROUP BY a.sku, a.region_name, a.instance_type, a.platform, b.description
ORDER BY a.region_name, a.instance_type, a.platform, a.sku
;
