# Load S3 CSVs to DynamoDB Table with AWS DMS
This Terraform setup is meant to setup the AWS DMS to transfer data stored into S3 CSVs to DynamoDB table. 

## Prerequisite
* Make sure your S3 bucket already exist and is in the same region as your DMS service

## DynamoDB Table Definition
[table_def.json](./modules/dms/assets/table_def.json) is currently having a sample table definition to load Employee data. Import path is set to `employee/` so make sure you save the CSV files under the `<bucket name>/<raw data path>/employee/` folder.

## Upload Data File to S3 
Import path is set to `employee/` so make sure you save the CSV files under the `<bucket name>/<raw data path>/employee/` folder.

## Post Terraform Apply
Once the AWS DMS is ready, upload the data file into the configured S3 bucket folder and start the DMS task.
