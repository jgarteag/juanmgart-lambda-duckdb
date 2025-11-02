terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Usar rol existente
data "aws_iam_role" "existing_lambda_role" {
  name = "depuente_role"
}

# S3 Bucket para archivos CSV
resource "aws_s3_bucket" "csv_files" {
  bucket = "${var.project_name}-csv-files-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Habilitar notificaciones EventBridge en el bucket
resource "aws_s3_bucket_notification" "csv_notification" {
  bucket      = aws_s3_bucket.csv_files.id
  eventbridge = true
}

# EventBridge Rule para capturar eventos S3
resource "aws_cloudwatch_event_rule" "s3_csv_upload" {
  name        = "${var.project_name}-s3-csv-upload"
  description = "Capture S3 CSV upload events"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [aws_s3_bucket.csv_files.bucket]
      }
      object = {
        key = [{
          suffix = ".csv"
        }]
      }
    }
  })
}

# EventBridge Target para Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_csv_upload.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.main.arn
}

# Permiso para EventBridge invocar Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_csv_upload.arn
}

data "aws_caller_identity" "current" {}

# Usar layer público - no necesitamos crear uno propio

# Crear ZIP del código Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../lambda/src"
  output_path = "lambda_function.zip"
}

# Función Lambda
resource "aws_lambda_function" "main" {
  filename         = "lambda_function.zip"
  function_name    = "${var.project_name}-lambda"
  role            = data.aws_iam_role.existing_lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60
  memory_size     = 512

  # Usar solo pandas por ahora (funciona 100%)
  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python311:13"
  ]

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = {
    Name = var.project_name
  }
}