resource "random_id" "random_id_prefix" {
  byte_length = 2
}
/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

provider "aws" {
  region  = "${var.region}"
}

module "networking" {
  source = "./modules/networking"

  region               = "${var.region}"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${local.production_availability_zones}"
}

module "dms" {
  source = "./modules/dms"

  region                     = "${var.region}"
  environment                = "${var.environment}"
  availability_zones         = "${local.production_availability_zones}"
  random_id                  = "${random_id.random_id_prefix.hex}"
  private_subnet_ids          = ["${module.networking.private_subnets_id}"]
  security_groups_ids        = ["${module.networking.default_sg_id}"]
  s3_bucket                  = "${var.s3_bucket}"
  raw_data_path              = "${var.raw_data_path}"
  allocated_storage          = "${var.allocated_storage}"
  apply_immediately          = "${var.apply_immediately}"
  auto_minor_version_upgrade = "${var.auto_minor_version_upgrade}"
  engine_version             = "${var.engine_version}"
  publicly_accessible        = "${var.publicly_accessible}"
  replication_instance_class = "${var.replication_instance_class}"
  migration_type             = "${var.migration_type}"

}
