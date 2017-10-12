
drop table if exists lookup_accounts cascade;

create table lookup_accounts
(linkedaccountid VARCHAR(12) NOT NULL,
accountname varchar(50) not NULL,
primary key (linkedaccountid)
);


drop table if exists lookup_regions;

create table lookup_regions
(region_short varchar(20) not null,
region_name varchar(40) not null,
primary key (region_short)
);

insert into lookup_regions values ('ap-northeast-1','Asia Pacific (Tokyo)');
insert into lookup_regions values ('ap-northeast-2','Asia Pacific (Seoul)');
insert into lookup_regions values ('ap-south-1','Asia Pacific (Mumbai)');
insert into lookup_regions values ('ap-southeast-1','Asia Pacific (Singapore)');
insert into lookup_regions values ('ap-southeast-2','Asia Pacific (Sydney)');
insert into lookup_regions values ('ca-central-1','Canada (Central)');
insert into lookup_regions values ('eu-central-1','EU (Frankfurt)');
insert into lookup_regions values ('eu-west-1','EU (Ireland)');
insert into lookup_regions values ('eu-west-2','EU (London)');
insert into lookup_regions values ('sa-east-1','South America (São Paulo)');
insert into lookup_regions values ('us-east-1','US East (N. Virginia)');
insert into lookup_regions values ('us-east-2','US East (Ohio)');
insert into lookup_regions values ('us-west-1','US West (N. California)');
insert into lookup_regions values ('us-west-2','US West (Oregon)');


drop table if exists lookup_days;

create table lookup_days
( yearmon varchar(6)
, days_in_month INTEGER
, hours_in_month INTEGER
, primary key (yearmon)
);


INSERT INTO lookup_days (yearmon, days_in_month, hours_in_month)
SELECT to_char(min(usagestartdate),'yyyymm') AS yearmon,
  DATE_PART('days', DATE_TRUNC('month', min(usagestartdate)) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL) AS days_in_month,
  DATE_PART('days', DATE_TRUNC('month', min(usagestartdate)) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL) * 24 AS hours_in_month
FROM dbr201707
union
SELECT to_char(min(usagestartdate),'yyyymm') AS yearmon,
  DATE_PART('days', DATE_TRUNC('month', min(usagestartdate)) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL) AS days_in_month,
  DATE_PART('days', DATE_TRUNC('month', min(usagestartdate)) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL) * 24 AS hours_in_month
FROM dbr201708
union
SELECT to_char(min(usagestartdate),'yyyymm') AS yearmon,
  DATE_PART('days', DATE_TRUNC('month', min(usagestartdate)) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL) AS days_in_month,
  DATE_PART('days', DATE_TRUNC('month', min(usagestartdate)) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL) * 24 AS hours_in_month
FROM dbr201709
HAVING to_char(min(usagestartdate),'yyyymm') NOT IN (SELECT yearmon FROM lookup_days)
;

-- SELECT * FROM lookup_days;
