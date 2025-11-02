#!/bin/bash
# Deployment script for Lambda DuckDB function

set -e

echo "🚀 Starting deployment of Lambda DuckDB function..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ Error: AWS CLI is not installed. Please install AWS CLI first."
    exit 1
fi

# Check AWS credentials
echo "🔑 Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS credentials not configured. Please configure AWS CLI."
    exit 1
fi

echo "✅ AWS credentials validated"

# Navigate to terraform directory
cd terraform

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Please edit terraform/terraform.tfvars with your configuration and run this script again."
    exit 0
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Validate Terraform configuration
echo "🔍 Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
read -p "Do you want to apply this plan? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled."
    rm -f tfplan
    exit 0
fi

# Apply deployment
echo "🚀 Deploying infrastructure..."
terraform apply tfplan

# Clean up plan file
rm -f tfplan

# Display outputs
echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Deployment outputs:"
terraform output

echo ""
echo "🎉 Lambda function deployed! You can now test it."
