
DROP TABLE IF EXISTS raw_pricing_rds;

CREATE TABLE raw_pricing_rds
( sku VARCHAR( 18 )
, termcode VARCHAR( 12 )
, termtype VARCHAR( 8 )
, description VARCHAR( 40 )
, effectdate date
, unit VARCHAR( 8 )
, price FLOAT(8)
, purchase_option VARCHAR( 15 )
, region_name VARCHAR( 24 )
, instance_type VARCHAR( 15 )
, current_gen VARCHAR( 3 )
, platform VARCHAR( 12 )
, edition varchar( 12 )
, licensing VARCHAR( 22 )
, deployment varchar( 28 )
, sriov VARCHAR( 3 )
, norm_factor varchar( 3 )
);

COPY raw_pricing_rds
FROM '/tmp/rds.csv'
DELIMITER '|'
NULL AS ''
CSV HEADER;


UPDATE raw_pricing_rds SET purchase_option = 'On-Demand' WHERE purchase_option IS NULL AND termtype = 'OnDemand';
UPDATE raw_pricing_rds SET norm_factor = null WHERE norm_factor = 'NA';

DROP TABLE IF EXISTS lookup_sku_rds;

CREATE TABLE lookup_sku_rds AS
SELECT DISTINCT region_name, platform, instance_type, sku, description, current_gen, licensing, COALESCE(sriov,'No') AS opt_sriov, norm_factor
FROM raw_pricing_rds
WHERE (sku, effectdate) IN (
    SELECT sku, max(effectdate) AS effectdate
    FROM raw_pricing_rds
    WHERE unit = 'Hrs'
    GROUP BY sku
)
AND description NOT IN ('Upfront Fee')
ORDER BY platform, instance_type, sku, description
;

CREATE UNIQUE INDEX idx_lookup_sku_rds ON lookup_sku_rds(sku);


DROP TABLE IF EXISTS pricing_rds;

CREATE TABLE pricing_rds AS
SELECT a.sku, a.region_name, a.instance_type, a.platform, a.deployment, b.description
, sum(on_demand_rph) AS on_demand_rph
, sum(no_upfront_rph) AS no_upfront_rph
, 0 as no_upfront_ot
, sum(partial_upfront_rph) AS partial_upfront_rph
, sum(partial_upfront_ot) AS partial_upfront_ot
, sum(all_upfront_rph) AS all_upfront_rph
, sum(all_upfront_ot) AS all_upfront_ot
FROM (
    SELECT sku, termcode, region_name, instance_type, platform, deployment
    , CASE termtype WHEN 'OnDemand' THEN price ELSE 0 END AS on_demand_rph
    , CASE purchase_option WHEN 'No Upfront' THEN CASE unit WHEN 'Hrs' THEN price ELSE 0 END ELSE 0 END AS no_upfront_rph
    , CASE purchase_option WHEN 'Partial Upfront' THEN CASE unit WHEN 'Hrs' THEN price ELSE 0 END ELSE 0 END AS partial_upfront_rph
    , CASE purchase_option WHEN 'Partial Upfront' THEN CASE unit WHEN 'Quantity' THEN price ELSE 0 END ELSE 0 END AS partial_upfront_ot
    , CASE purchase_option WHEN 'All Upfront' THEN CASE unit WHEN 'Hrs' THEN price ELSE 0 END ELSE 0 END AS all_upfront_rph
    , CASE purchase_option WHEN 'All Upfront' THEN CASE unit WHEN 'Quantity' THEN price ELSE 0 END ELSE 0 END AS all_upfront_ot
    , unit
    FROM raw_pricing_rds
) AS a, lookup_sku_rds b
WHERE a.sku = b.sku
GROUP BY a.sku, a.region_name, a.instance_type, a.platform, a.deployment, b.description
ORDER BY a.region_name, a.instance_type, a.platform, a.sku, a.deployment
;
