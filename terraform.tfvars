region      = "eu-central-1"
environment = "production"

/* VPC, CIDR, and Subnets */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]

/* AWS DMS Source S3 Bucket */
s3_bucket     = "appgambit-dms-testing"
raw_data_path = "import_data"

/* AWS DMS Replication Instance Config */
allocated_storage          = 10
apply_immediately          = true
auto_minor_version_upgrade = true
engine_version             = "3.1.4"
publicly_accessible        = false
replication_instance_class = "dms.t2.micro"

/* AWS DMS Migration Task Config */
migration_type = "full-load"