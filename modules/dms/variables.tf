variable "environment" {
  description = "The Deployment environment"
}

variable "random_id" {
  description = "random_id"
}

variable "region" {
  description = "region"
}

variable "availability_zones" {
  type        = list
  description = "availability zones"
}

variable "private_subnet_ids" {
  type        = list
  description = "private subnet ids"
}

variable "security_groups_ids" {
  type        = list
  description = "security groups ids"
}

variable "s3_bucket" {
  description = "s3 bucket name"
}

variable "raw_data_path" {
  description = "Folder name of row data"
}

/* aws_dms_replication_instance */
variable "allocated_storage" {
  description = "Size of replication instance"
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

/* aws_dms_replication_task */
variable "migration_type" {
  description = "migration type"
}
