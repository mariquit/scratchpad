
DROP TABLE IF EXISTS dbr201709;

CREATE TABLE dbr201709
( invoiceid VARCHAR( 40 )
, payeraccountid VARCHAR( 12 ) NOT NULL
, linkedaccountid VARCHAR( 12 )
, recordtype VARCHAR(20)
, recordid VARCHAR( 255 )
, productname VARCHAR( 255 )
, rateid VARCHAR(20)
, subscriptionid VARCHAR(20)
, pricingplanid VARCHAR(20)
, usagetype VARCHAR( 255 )
, operation VARCHAR( 255 )
, availabilityzone VARCHAR( 16 )
, reservedinstance VARCHAR(1)
, itemdescription VARCHAR( 255 )
, usagestartdate TIMESTAMP
, usageenddate TIMESTAMP
, usagequantity FLOAT(8)
, blendedrate FLOAT(8)
, blendedcost FLOAT(8)
, unblendedrate FLOAT(8)
, unblendedcost FLOAT(8)
, resourceid VARCHAR( 255 )
, aws_asg_groupname VARCHAR( 255 )
, aws_cfn_logical_id VARCHAR( 255 )
, aws_cfn_stack_id VARCHAR( 255 )
, aws_cfn_stack_name VARCHAR( 255 )
, aws_emr_res_grp_role VARCHAR( 255 )
, aws_emr_job_flow_id VARCHAR( 255 )
, tag_customer VARCHAR( 255 )
, tag_name VARCHAR( 255 )
);

COPY dbr201709
FROM '/Users/john.mariquit/Downloads/dbr201709.fixed' 
DELIMITER '|'
NULL AS ''
CSV HEADER;


/* new tag called "Customer" was added in Sep 2017 */
ALTER TABLE dbr201707 ADD COLUMN IF NOT EXISTS tag_customer VARCHAR(255);
ALTER TABLE dbr201708 ADD COLUMN IF NOT EXISTS tag_customer VARCHAR(255);

/* I'm proposing to add an "Environment" and a "Project/Product" tag */
ALTER TABLE dbr201707 ADD COLUMN IF NOT EXISTS tag_env VARCHAR(255);
ALTER TABLE dbr201708 ADD COLUMN IF NOT EXISTS tag_env VARCHAR(255);
ALTER TABLE dbr201709 ADD COLUMN IF NOT EXISTS tag_env VARCHAR(255);

ALTER TABLE dbr201707 ADD COLUMN IF NOT EXISTS tag_pro VARCHAR(255);
ALTER TABLE dbr201708 ADD COLUMN IF NOT EXISTS tag_pro VARCHAR(255);
ALTER TABLE dbr201709 ADD COLUMN IF NOT EXISTS tag_pro VARCHAR(255);