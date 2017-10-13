DROP TABLE IF EXISTS ec2_ri_breakdown;

CREATE TABLE ec2_ri_breakdown
AS
SELECT linkedaccountid, instance_id, availabilityzone, b.region_name, a.instance_type, description as platform
, count(a.yearmon) AS months_running
, min(a.yearmon) AS min_month, max(a.yearmon) AS max_month
, min(usagepct) AS min_usage, avg(usagepct)::FLOAT(8) AS avg_usage
, sum(usagecosts)::decimal(10,2) AS cost_per_3mos
, sum(usagehours) as hour_per_3mos
, sum(weight::INT) AS weight
, sku
, (hours_in_month*on_demand_rph)::decimal(10,2) as on_demand_monthly
, (hours_in_month*on_demand_rph*12)::decimal(10,2) as on_demand_annual
, (hours_in_month*no_upfront_rph)::decimal(10,2) as no_upfront_monthly
, (hours_in_month*no_upfront_rph*12)::decimal(10,2) as no_upfront_annual
, no_upfront_ot as no_upfront_onetime
, (hours_in_month*partial_upfront_rph)::decimal(10,2) as partial_upfront_monthly
, (hours_in_month*partial_upfront_rph*12)::decimal(10,2) as partial_upfront_annual
, partial_upfront_ot as partial_upfront_onetime
, all_upfront_rph as all_upfront_monthly
, all_upfront_rph as all_upfront_annual
, all_upfront_ot as all_upfront_onetime
FROM (
    SELECT * FROM ec2_usage
    WHERE usagepct > 70
    AND reservedinstance = 'N'
) AS a, lookup_regions b, pricing_ec2 c, lookup_days d
where a.region_short = b.region_short
and a.platform = c.description
and a.instance_type = c.instance_type
and b.region_name = c.region_name
GROUP BY linkedaccountid, instance_id, availabilityzone, b.region_name, a.instance_type, description, sku, on_demand_rph, no_upfront_rph, no_upfront_ot, partial_upfront_rph, partial_upfront_ot, all_upfront_rph, all_upfront_ot, hours_in_month, d.yearmon
having max(a.yearmon) = d.yearmon
order by instance_id
;

DROP TABLE IF EXISTS ec2_ri_summary;

CREATE TABLE ec2_ri_summary
AS
select linkedaccountid
, count(instance_id) as instance_count
, region_name
, availabilityzone
, instance_type
, platform
, sum(on_demand_monthly)::decimal(10,2) as on_demand_monthly
, sum(on_demand_annual)::decimal(10,2) as on_demand_annual
, sum(no_upfront_monthly)::decimal(10,2) as no_upfront_monthly
, sum(no_upfront_annual)::decimal(10,2) as no_upfront_annual
, sum(no_upfront_onetime)::decimal(10,2) as no_upfront_onetime
, sum(partial_upfront_monthly)::decimal(10,2) as partial_upfront_monthly
, sum(partial_upfront_annual)::decimal(10,2) as partial_upfront_annual
, sum(partial_upfront_onetime)::decimal(10,2) as partial_upfront_onetime
, sum(all_upfront_monthly)::decimal(10,2) as all_upfront_monthly
, sum(all_upfront_annual)::decimal(10,2) as all_upfront_annual
, sum(all_upfront_onetime)::decimal(10,2) as all_upfront_onetime
, weight
from ec2_ri_breakdown
where weight > 3
group by linkedaccountid, region_name, availabilityzone, instance_type, platform, weight
order by linkedaccountid, region_name, instance_type, platform;


DROP TABLE IF EXISTS rds_ri_breakdown;

CREATE TABLE rds_ri_breakdown
AS
SELECT linkedaccountid, instance_id, availabilityzone
, b.region_name, a.instance_type, description as platform
, count(a.yearmon) AS months_running
, min(a.yearmon) AS min_month, max(a.yearmon) AS max_month
, min(usagepct) AS min_usage, avg(usagepct)::FLOAT(8) AS avg_usage
, sum(usagecosts)::decimal(10,2) AS cost_per_3mos
, sum(usagehours) as hour_per_3mos
, sum(weight::INT) AS weight
, sku
, (hours_in_month*on_demand_rph)::decimal(10,2) as on_demand_monthly
, (hours_in_month*on_demand_rph*12)::decimal(10,2) as on_demand_annual
, (hours_in_month*no_upfront_rph)::decimal(10,2) as no_upfront_monthly
, (hours_in_month*no_upfront_rph*12)::decimal(10,2) as no_upfront_annual
, no_upfront_ot as no_upfront_onetime
, (hours_in_month*partial_upfront_rph)::decimal(10,2) as partial_upfront_monthly
, (hours_in_month*partial_upfront_rph*12)::decimal(10,2) as partial_upfront_annual
, partial_upfront_ot as partial_upfront_onetime
, all_upfront_rph as all_upfront_monthly
, all_upfront_rph as all_upfront_annual
, all_upfront_ot as all_upfront_onetime
FROM (
    SELECT * FROM rds_usage
    WHERE usagepct > 70
    AND reservedinstance = 'N'
 ) AS a, lookup_regions b, pricing_rds c, lookup_days d
where a.availabilityzone = b.region_short
and a.platform = c.description
and a.instance_type = c.instance_type
and b.region_name = c.region_name
AND c.deployment in ('Single-AZ')
GROUP BY linkedaccountid, instance_id, availabilityzone, b.region_name, a.instance_type, description, sku, on_demand_rph, no_upfront_rph, no_upfront_ot, partial_upfront_rph, partial_upfront_ot, all_upfront_rph, all_upfront_ot, hours_in_month, d.yearmon
having max(a.yearmon) = d.yearmon
order by instance_id
;

DROP TABLE IF EXISTS rds_ri_summary;

CREATE TABLE rds_ri_summary
AS
select linkedaccountid
, count(instance_id) as instance_count
, region_name
, availabilityzone
, instance_type
, platform
, sum(on_demand_monthly)::decimal(10,2) as on_demand_monthly
, sum(on_demand_annual)::decimal(10,2) as on_demand_annual
, sum(no_upfront_monthly)::decimal(10,2) as no_upfront_monthly
, sum(no_upfront_annual)::decimal(10,2) as no_upfront_annual
, sum(no_upfront_onetime)::decimal(10,2) as no_upfront_onetime
, sum(partial_upfront_monthly)::decimal(10,2) as partial_upfront_monthly
, sum(partial_upfront_annual)::decimal(10,2) as partial_upfront_annual
, sum(partial_upfront_onetime)::decimal(10,2) as partial_upfront_onetime
, sum(all_upfront_monthly)::decimal(10,2) as all_upfront_monthly
, sum(all_upfront_annual)::decimal(10,2) as all_upfront_annual
, sum(all_upfront_onetime)::decimal(10,2) as all_upfront_onetime
, weight
from rds_ri_breakdown
where weight > 3
group by linkedaccountid, region_name, availabilityzone, instance_type, platform, weight
order by linkedaccountid, region_name, instance_type, platform;
