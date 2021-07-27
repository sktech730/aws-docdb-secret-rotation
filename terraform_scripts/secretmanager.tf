#======================
# Define Current Region
#======================

data "aws_region" "current" {}

#==========================
# Define Current Calller ID
#==========================

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "sample-documentdb" {
  name = "sample-documentdb"
  recovery_window_in_days = 0
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "sample-docdb_secret_version" {
  secret_id = aws_secretsmanager_secret.sample-documentdb.id
  secret_string = jsonencode(
  {
    "engine" : "mongo",
    "username": var.master_docdb_user
    "password": var.master_docdb_password,
    "host": aws_docdb_cluster.sample.endpoint
    "port": aws_docdb_cluster.sample.port
    "dbClusterIdentifier": aws_docdb_cluster.sample.cluster_identifier
    "uri": join("", [
      "mongodb://",
      aws_docdb_cluster.sample.endpoint,
      ":27017/?replicaSet=rs0&readPreference=secondaryPreferred"])
  }
  )
}

resource "aws_secretsmanager_secret_rotation" "sample-docdb_secret_roration" {
  secret_id = aws_secretsmanager_secret.sample-documentdb.id
  rotation_lambda_arn = aws_lambda_function.docdb-rotate-lambda.arn
  rotation_rules {
    automatically_after_days = var.secret_rotation_frequency
  }
}

# Multi user rotation

### configure secondary user secret

resource "aws_secretsmanager_secret" "sample-documentdb-app-user" {
  name = "sample-documentdb-app-usr"
  recovery_window_in_days = 0
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "sample-documentdb-app-user" {
  secret_id = aws_secretsmanager_secret.sample-documentdb-app-user.id
  secret_string = jsonencode(
  {
    "masterarn": aws_secretsmanager_secret.sample-documentdb.arn
    "engine" : "mongo",
    "username": var.sample_app_user,
    "password": var.docdb_app_usr_password,
    "host": aws_docdb_cluster.sample.endpoint
    "port": aws_docdb_cluster.sample.port
    "dbClusterIdentifier": aws_docdb_cluster.sample.cluster_identifier
    "uri": join("", [
      "mongodb://",
      aws_docdb_cluster.sample.endpoint,
      ":27017/?replicaSet=rs0&readPreference=secondaryPreferred"])
  }
  )
}

resource "aws_secretsmanager_secret_rotation" "sample-documentdb-app-user" {
  secret_id = aws_secretsmanager_secret.sample-documentdb-app-user.id
  rotation_lambda_arn = aws_lambda_function.app-user-docdb-rotate-lambda.arn
  rotation_rules {
    automatically_after_days = var.secret_rotation_frequency
  }
}

data "archive_file" "docdb_lambda_function" {
  type = "zip"
  output_file_mode = "0666"
  source_dir = "${path.module}/../src/docdb_rotate/"
  output_path = "${path.module}/files/docdb_rotate.zip"
}

### Lambda to rotate the docdb password
resource "aws_lambda_function" "docdb-rotate-lambda" {
  depends_on = [
    data.archive_file.docdb_lambda_function]
  filename = data.archive_file.docdb_lambda_function.output_path
  function_name = "sample-docdb-rotate-password"
  role = aws_iam_role.sample-lambda-dbpassword-rotate-role.arn
  handler = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.docdb_lambda_function.output_path)
  timeout = 600
  runtime = "python3.8"
  vpc_config {
    subnet_ids = [
      var.private-subnet-1,
      var.private-subnet-2
    ]
    security_group_ids = [
      aws_security_group.sample.id]
  }

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

data "archive_file" "app-user-docdb_lambda_function" {
  type = "zip"
  output_file_mode = "0666"
  source_dir = "${path.module}/../src/docdb_multiuser_rotate/"
  output_path = "${path.module}/files/docdb_multiuser_rotate.zip"
}

### Lambda to rotate the app user docdb password
resource "aws_lambda_function" "app-user-docdb-rotate-lambda" {
  depends_on = [
    data.archive_file.app-user-docdb_lambda_function]
  filename = data.archive_file.app-user-docdb_lambda_function.output_path
  function_name = "app-user-docdb-rotate-password"
  role = aws_iam_role.sample-lambda-dbpassword-rotate-role.arn
  handler = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.app-user-docdb_lambda_function.output_path)
  timeout = 600
  runtime = "python3.8"
  vpc_config {
    subnet_ids = [
      var.private-subnet-1,
      var.private-subnet-2
    ]
    security_group_ids = [
      aws_security_group.sample.id]
  }

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_iam_role" "sample-lambda-dbpassword-rotate-role" {
  name = "sample-lambda-dbpassword-rotate-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "sample-lambda-secrets-policy" {
  name = "sample_lambda_secrets_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "secretsmanager:DescribeSecret",
              "secretsmanager:GetSecretValue",
              "secretsmanager:PutSecretValue",
              "secretsmanager:UpdateSecretVersionStage"
          ],

          "Resource": "*"
      },
      {
          "Action": [
              "secretsmanager:GetRandomPassword"
          ],

          "Resource": "*",
          "Effect": "Allow"
      },
      {
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
        ],
        "Resource": "*",
        "Effect": "Allow"
      }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "sample-secret-rotation-policy-attachment" {
  name = "sample-secret-rotation-policy-attachment"
  policy_arn = aws_iam_policy.sample-lambda-secrets-policy.arn
  roles = [
    aws_iam_role.sample-lambda-dbpassword-rotate-role.name]
}

resource "aws_lambda_permission" "lambda_permission_to_invoked_by_secret_manager" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docdb-rotate-lambda.function_name
  principal = "secretsmanager.amazonaws.com"
}

resource "aws_lambda_permission" "app-user-lambda_permission_to_invoked_by_secret_manager" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app-user-docdb-rotate-lambda.function_name
  principal = "secretsmanager.amazonaws.com"
}

resource "aws_vpc_endpoint" "secret_manager_end_point" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.private-subnet-1,
    var.private-subnet-2
  ]
  security_group_ids = [
    aws_security_group.sample.id]
  tags = local.common_tags
}