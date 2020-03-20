# Create a new replication subnet group
resource "aws_dms_replication_subnet_group" "dms_replication_subnet_group" {
  replication_subnet_group_description = "replication subnet group"
  replication_subnet_group_id          = "replication-subnet-group-tf-${var.random_id}"

  subnet_ids = flatten(["${var.private_subnet_ids}"])

  tags = {
    Name = "dms_replication_subnet_group"
  }
}

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms_access_for_endpoint" {
  assume_role_policy = "${data.aws_iam_policy_document.dms_assume_role.json}"
  name               = "${var.random_id}-dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint_IAMFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
  role       = "${aws_iam_role.dms_access_for_endpoint.name}"
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.dms_access_for_endpoint.name}"
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint_AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "${aws_iam_role.dms_access_for_endpoint.name}"
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint_AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = "${aws_iam_role.dms_access_for_endpoint.name}"
}

# Create a new replication instance
resource "aws_dms_replication_instance" "dms_replication_instance" {
  allocated_storage           = "${var.allocated_storage}"
  apply_immediately           = "${var.apply_immediately}"
  auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"
  engine_version              = "${var.engine_version}"
  publicly_accessible         = "${var.publicly_accessible}"
  replication_instance_class  = "${var.replication_instance_class}"
  replication_instance_id     = "dms-replication-instance-tf-${var.random_id}"
  replication_subnet_group_id = "${aws_dms_replication_subnet_group.dms_replication_subnet_group.id}"

  tags = {
    Name = "${var.random_id}-dms_replication_instance"
  }

  vpc_security_group_ids = "${var.security_groups_ids}"
}

data "template_file" "table_def" {
  template = "${file("${path.module}/assets/table_def.json")}"
}

# Create csv_to_dynamodb_source endpoint
resource "aws_dms_endpoint" "csv_to_dynamodb_source" {

  endpoint_id = "csv-to-dynamodb-source-${var.random_id}"

  endpoint_type               = "source"
  engine_name                 = "s3"
  extra_connection_attributes = ""
  service_access_role         = "${aws_iam_role.dms_access_for_endpoint.arn}"

  s3_settings {
    service_access_role_arn   = "${aws_iam_role.dms_access_for_endpoint.arn}"
    bucket_name               = "${var.s3_bucket}"
    bucket_folder             = "${var.raw_data_path}"
    compression_type          = "NONE"
    external_table_definition = "${data.template_file.table_def.rendered}"
    csv_row_delimiter         = "\\n"
    csv_delimiter             = ","
  }

  tags = {
    Name = "csv_to_dynamodb_source"
  }
}

# Create csv_to_dynamodb_target endpoint
resource "aws_dms_endpoint" "csv_to_dynamodb_target" {

  endpoint_id = "csv-to-dynamodb-target-${var.random_id}"

  endpoint_type               = "target"
  engine_name                 = "dynamodb"
  extra_connection_attributes = ""
  service_access_role         = "${aws_iam_role.dms_access_for_endpoint.arn}"

  tags = {
    Name = "csv_to_dynamodb_target"
  }
}


# Reference the DMS table mappings
data "template_file" "table_mappings" {
  template = "${file("${path.module}/assets/table_mappings.tpl")}"
}

data "template_file" "replication_task_settings" {
  template = "${file("${path.module}/assets/replication_task_settings.json")}"
}

# Create a new replication task
resource "aws_dms_replication_task" "dms_replication_task" {

  migration_type            = "${var.migration_type}"
  replication_instance_arn  = "${aws_dms_replication_instance.dms_replication_instance.replication_instance_arn}"
  replication_task_id       = "dms-replication-task-tf-${var.random_id}"
  replication_task_settings = "${data.template_file.replication_task_settings.rendered}"
  source_endpoint_arn       = "${aws_dms_endpoint.csv_to_dynamodb_source.endpoint_arn}"
  # table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

  table_mappings = "${data.template_file.table_mappings.rendered}"

  tags = {
    Name = "dms_replication_task"
  }

  target_endpoint_arn = "${aws_dms_endpoint.csv_to_dynamodb_target.endpoint_arn}"
}
