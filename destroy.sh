#!/bin/bash
# Destroy script for Lambda DuckDB infrastructure

set -e

echo "🗑️  Starting destruction of Lambda DuckDB infrastructure..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed."
    exit 1
fi

# Navigate to terraform directory
cd terraform

# Check if terraform state exists
if [ ! -f terraform.tfstate ]; then
    echo "❌ No Terraform state found. Nothing to destroy."
    exit 1
fi

# Show what will be destroyed
echo "📋 Planning destruction..."
terraform plan -destroy

echo ""
echo "⚠️  WARNING: This will destroy all resources created by Terraform!"
echo ""
read -p "Are you sure you want to destroy the infrastructure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Destruction cancelled."
    exit 0
fi

# Destroy infrastructure
echo "🗑️  Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "✅ Infrastructure destroyed successfully!"
