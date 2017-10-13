# Doing a Reserved Instance Analysis using the AWS DBR (Detailed Billing Report) via PostgreSQL

### Prerequisites

* DBR file already imported into your local PostgreSQL database (see aws_billing tree)
* Python 2.7
* PostgreSQL database (running on local machine preferably)
* psql (or any PostgreSQL SQL UI/IDE)
* Linux or OSX (sorry Windows users.  It might work under cygwin but I've never tested it with cygwin)

### Database Setup

This requires the use of the same DBR database.  Refer to the [aws_billing](../aws_billing) project for the setup.

### Usage

Simply run the `reinitdb.sh` script and it will pull the data from the AWS Pricing API and create the necessary summary tables.

When it is done processing all you have to do is to run a simple query like:
```
select * from ec2_ri_summary
```
and
```
select * from rds_ri_summary
```
to get to a nice summary page that shows on-demand vs no upfront vs partial upfront vs all upfront.  
> Note that this only takes into consideration 1-year RI purchase options.  If you want to include 3-year purchase options, that is left as an exercise for you.

And if you need the details/breakdown of the summaries provided, you simply run the query:
```
select * from ec2_ri_breakdown
```
or
```
select * from rds_ri_breakdown
```

## To Do

* [ ] add support for Amazon RedShift Reserved Nodes
* [ ] add support for AWS DynamoDB Reserved Capacity
* [ ] add support for AWS ElastiCache Reserved
* [ ] add support for Amazon CloudFront Reserved Capacity

## Built With

* [vi](https://en.wikipedia.org/wiki/Vi) - The editor I used for creating the scripts
* [Docker](https://www.docker.com/) - Docker for running the PostgreSQL local DB on OSX
* [Valentina Studio](https://www.valentina-db.com/en/valentina-studio-overview) - SQL UI tool I used for running the queries
