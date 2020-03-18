variable "region" {
  description = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "s3_bucket" {
  description = "s3 bucket name"
}

variable "raw_data_path" {
  description = "Folder name of row data"
}

variable "allocated_storage" {
  description = "Size of replication instance in GB"
}

variable "apply_immediately" {
  description = "apply immediately"
}

variable "auto_minor_version_upgrade" {
  description = "auto minor version upgrade"
}

variable "engine_version" {
  description = "engine version"
}

variable "publicly_accessible" {
  description = "publicly accessible"
}

variable "replication_instance_class" {
  description = "replication instance class"
}

variable "migration_type" {
  description = "migration type"
}