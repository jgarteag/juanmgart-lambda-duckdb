# Lambda + DuckDB Project

Proyecto hands-on para desplegar una función Lambda con DuckDB usando Terraform.

## Prerrequisitos

- AWS CLI configurado
- Terraform instalado
- Python 3.11+

## Configuración

1. Copia el archivo de ejemplo:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. Edita `terraform/terraform.tfvars` con tus valores:
   ```hcl
   aws_region = "us-east-1"
   aws_profile = "tu-perfil-aws"
   project_name = "lambda-duckdb"
   ```

## Despliegue

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Prueba

```bash
aws lambda invoke --function-name lambda-duckdb-lambda --profile tu-perfil response.json
cat response.json
```

## Limpieza

```bash
terraform destroy
```