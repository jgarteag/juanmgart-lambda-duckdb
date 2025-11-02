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
  timeout         = 30

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = {
    Name = var.project_name
  }
}