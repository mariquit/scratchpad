# Processing AWS DBR (Detailed Billing Report) with PostgreSQL

In order to process (a.k.a data mine) the detailed billing report, Amazon typically recommends the use of AWS Athena (for smaller files) or AWS RedShift (sometimes together with EMR to process large files -- yes, I've seen DBR files that are at least 12GB in size).  

This approach takes a more cost-efficient path by utilizing a local PostgreSQL database.  For reporting purposes, it will be sufficient.

### Prerequisites

* DBR file already downloaded from your S3 billing bucket (and un-gzipped)
* Python 2.7
* PostgreSQL database (running on local machine preferably)
* psql (or any PostgreSQL SQL UI/IDE)
* Linux or OSX (sorry Windows users.  It might work under cygwin but I've never tested it with cygwin)

### Database Setup

After downloading (and unpacking) the DBR file from the S3 bucket, you should have a .CSV file to work with.  For this guide, we will call the DBR CSV file as **_dbr.csv_**.

You can grab the first line of the DBR file to get the column headers. Let's add a newline while we're at it :simple_smile:

Run the following shell command:
```
head -1 dbr.csv | tr ',' '\n'
```

You will see something like:

> "InvoiceID"
"PayerAccountId"
"LinkedAccountId"
"RecordType"
"RecordId"
"ProductName"
"RateId"
"SubscriptionId"
"PricingPlanId"
"UsageType"
"Operation"
"AvailabilityZone"
"ReservedInstance"
"ItemDescription"
"UsageStartDate"
"UsageEndDate"
"UsageQuantity"
"BlendedRate"
"BlendedCost"
"UnBlendedRate"
"UnBlendedCost"
"ResourceId"
"aws:autoscaling:groupName"
"aws:cloudformation:logical-id"
"aws:cloudformation:stack-id"
"aws:cloudformation:stack-name"
"aws:elasticmapreduce:instance-group-role"
"aws:elasticmapreduce:job-flow-id"
"user:Name"

Take note that some of the fields are not fixed -- may or may not be present in your DBR file.  The standard columns/fields are from the **_InvoiceID_** up to the **_ResourceId_**.  Any field that comes after the *ResourceId* (like the aws:autoscaling:groupName in the above-example) varies depending on the tags you have activated in your billing preferences.

Once you have the header, you can create a database DDL as such, and run via your SQL CLI (or UI tool):
```
CREATE TABLE dbr2017 (
  invoiceid varchar(40),
  payeraccountid varchar(12) NOT NULL,
  linkedaccountid varchar(12),
  recordtype varchar(20),
  recordid varchar(255),
  productname varchar(255),
  rateid varchar(20),
  subscriptionid varchar(20),
  pricingplanid varchar(20),
  usagetype varchar(255),
  operation varchar(255),
  availabilityzone varchar(16),
  reservedinstance varchar(1),
  itemdescription varchar(255),
  usagestartdate timestamp,
  usageenddate timestamp,
  usagequantity float(8),
  blendedrate float(8),
  blendedcost float(8),
  unblendedrate float(8),
  unblendedcost float(8),
  resourceid varchar(255),
  aws_asg_groupname varchar(255),
  aws_cfn_logical_id varchar(255),
  aws_cfn_stack_id varchar(255),
  aws_cfn_stack_name varchar(255),
  aws_emr_res_grp_role varchar(255),
  aws_emr_job_flow_id varchar(255),
  tag_customer varchar(255),
  tag_name varchar(255)
);
```

Execute the DDL and we're almost ready to import the **_dbr.csv_** into our PostgreSQL database.  

But not quite yet...   AWS Redshift and Athena excels in parsing their DBR file.  PostgreSQL however fumbles through the CSV (have difficulties in parsing quoted commas `abc,def,"ghi, jkl",mno` -- instead of ending up with four fields, the previous string becomes five fields i.e. splits `"ghi, jkl"` into two fields).

So we need to fix the CSV.  Go back to your shell and run the CSV file through the csvfix-dbr:
```
csvfix-dbr dbr.csv > /tmp/dbr.fixed.txt
```
or
```
cat dbr.csv | csvfix-dbr - > /tmp/dbr.fixed.txt
```

From this point onwards, we will be using the generated **_/tmp/dbr.fixed.txt_** file for loading into Postgres.  We can proceed to load the file via SQL:
```
COPY dbr2017
FROM '/tmp/dbr.fixed.txt'
DELIMITER '|'
NULL AS ''
CSV HEADER;
```

Congratulations!  You now have a queryable version of your AWS Detailed Billing Report.

## Sample Queries

`Top 5 Resources Across Regions and Services`
```
SELECT productname,
  COUNT(DISTINCT resourceid) AS num_instances,
  COUNT(DISTINCT availabilityzone) AS num_AZ
FROM dbr2017
GROUP BY productname
ORDER BY 2 DESC LIMIT 5;
```
gives you something like:

| productname | num_instances | num_AZ |
| --- | --- | --- |
| Amazon Elastic Compute Cloud | 7345 | 9 |
| AmazonCloudWatch | 399 | 0 |
| Amazon Simple Storage Service | 117 | 0 |
| Amazon RDS Service | 78 | 3 |
| Amazon Elastic MapReduce | 63 | 0 |

---

`Top 5 Services based on Cost`
```
SELECT productname,
  SUM(unblendedcost)::decimal(10,2) AS cost
FROM dbr2017
WHERE recordtype = 'LineItem'
AND productname IS NOT NULL
GROUP BY productname
ORDER BY 2 DESC LIMIT 5;
```
gives you something like:

| productname | cost |
| --- | --- |
| Amazon Elastic Compute Cloud | 5943.45 |
| Amazon RDS Service | 1405.78 |
| Amazon Redshift | 371.50 |
| Amazon Kinesis | 285.90 |
| Amazon DynamoDB | 211.69 |


## Quo Vadis

The DBR records contains tons of fields and have hundreds/thousands of lines.  I am providing these additional queries to help format the data into a more usable content.

Table: `EC2`
```
CREATE TABLE ec2 AS
SELECT linkedaccountid,
  resourceid AS instance_id,
  SPLIT_PART(usagetype,'BoxUsage:',2) AS instance_type,
  CASE reservedinstance
  WHEN 'Y' THEN TRIM(TRAILING ', ' FROM SPLIT_PART(SPLIT_PART(itemdescription,'per ',2),SPLIT_PART(usagetype,'BoxUsage:',2),1))
  ELSE SPLIT_PART(split_part(itemdescription,'Demand ',2),SPLIT_PART(usagetype,'BoxUsage:',2),1)
  END AS platform,
  availabilityzone,
  SUBSTRING(availabilityzone,1,POSITION('-' IN SUBSTRING(availabilityzone,4,LENGTH(availabilityzone)))+4) AS region_short,
  reservedinstance,
  unblendedcost,
  usagequantity,
  DATE_PART('hour',usageenddate-usagestartdate)::INTEGER AS hours,
  tag_name,
  usagestartdate,
  usageenddate
FROM dbr2017
WHERE productname ILIKE '%compute cloud%'
  AND usagetype ILIKE '%boxusage%'
  AND operation ILIKE '%runinstance%'
  AND recordtype = 'LineItem'
  AND itemdescription NOT ILIKE '%subscription%'
  AND itemdescription NOT ILIKE '%recurring fee%';
```
then you can run a report query like:
```
SELECT count(DISTINCT instance_id) AS num_instances,
       instance_type,
       platform,
       region_short
FROM ec2
GROUP BY instance_type,
         platform,
         region_short
ORDER BY 1 DESC
LIMIT 5;
```
that gives you something like the top 5 EC2 instance types used for the month:

| num_instances | instance_type | platform | region_short |
| --- | --- | --- | --- |
| 3218 | t2.micro | Linux | ap-southeast-1 |
| 745 | c4.2xlarge | Linux | us-east-1 |
| 275 | m4.large | Linux | ap-southeast-1 |
| 242 | t2.medium | Linux | ap-southeast-1 |
| 186 | m4.xlarge | Linux | us-east-1 |

---

Table: `RDS`
```
CREATE TABLE rds AS
SELECT linkedaccountid,
  SPLIT_PART(resourceid,'db:',2) AS instance_id,
  SPLIT_PART(usagetype,'Usage:',2) AS instance_type,
  SPLIT_PART(split_part(itemdescription,'running ',2),
  SPLIT_PART(usagetype,'Usage:',2),1) AS platform,
  availabilityzone,
  SUBSTRING(availabilityzone,1,POSITION('-' IN SUBSTRING(availabilityzone,4,LENGTH(availabilityzone)))+4) AS region_short,
  reservedinstance,
  unblendedcost,
  usagequantity,
  DATE_PART('hour',usageenddate-usagestartdate)::INTEGER AS hours,
  tag_name,
  usagestartdate,
  usageenddate
FROM dbr2017
WHERE productname ILIKE '%rds service%'
  AND operation ILIKE '%createdbinstance%'
  AND usagetype ILIKE '%instanceusage%'
  AND recordtype = 'LineItem'
  AND itemdescription ILIKE '%running%';
```
then you can run a report query like the EC2 one (this time for RDS):
```
SELECT count(DISTINCT instance_id) AS num_instances,
       instance_type,
       platform,
       region_short
FROM rds
GROUP BY instance_type,
         platform,
         region_short
ORDER BY 1 DESC
LIMIT 5;
```
that gives you something like the top 5 RDS instance types used for the month:

| num_instances | instance_type | platform | region_short |
| --- | --- | --- | --- |
| 62 | db.t2.small | PostgreSQL | ap-southeast-1 |
| 4 | db.t2.small | MySQL | ap-southeast-1 |
| 3 | db.t2.small | PostgreSQL | us-east-1 |
| 2 | db.t2.medium | MySQL | us-west-2 |
| 1 | db.t2.micro | SQL Server Express (LI) | us-west-2 |


## Built With

* [vi](https://en.wikipedia.org/wiki/Vi) - The editor I used for creating the scripts
* [Docker](https://www.docker.com/) - Docker for running the PostgreSQL local DB on OSX
* [Valentina Studio](https://www.valentina-db.com/en/valentina-studio-overview) - SQL UI tool I used for running the queries
