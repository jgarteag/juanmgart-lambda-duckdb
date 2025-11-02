# 🚀 Guía de Inicio Rápido

Esta guía te ayudará a desplegar rápidamente la función Lambda con DuckDB en AWS.

## ⚡ Inicio Rápido (5 minutos)

### Prerequisitos

```bash
# Verificar que tienes todo instalado
python3 --version    # Python 3.11+
terraform --version  # Terraform 1.0+
aws --version        # AWS CLI

# Verificar credenciales AWS
aws sts get-caller-identity
```

### Paso 1: Clonar y Configurar

```bash
# Clonar el repositorio
git clone https://github.com/jgarteag/juanmgart-lambda-duckdb.git
cd juanmgart-lambda-duckdb

# Instalar dependencias (opcional, para desarrollo local)
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Paso 2: Configurar Variables de Terraform

```bash
# Copiar archivo de variables de ejemplo
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars (opcional)
# vim terraform.tfvars
```

Contenido por defecto (ya está listo para usar):
```hcl
aws_region          = "us-east-1"
environment         = "dev"
function_name       = "juanmgart-duckdb-lambda"
lambda_timeout      = 60
lambda_memory_size  = 512
log_retention_days  = 7
enable_function_url = true
```

### Paso 3: Desplegar

```bash
# Opción 1: Usando el script de deployment
cd ..
./deploy.sh

# Opción 2: Manualmente
cd terraform
terraform init
terraform plan
terraform apply
```

### Paso 4: Probar la Función

```bash
# Opción 1: Usando AWS CLI
aws lambda invoke \
  --function-name juanmgart-duckdb-lambda \
  --payload '{}' \
  response.json && cat response.json

# Opción 2: Usando Function URL (si está habilitada)
FUNCTION_URL=$(cd terraform && terraform output -raw lambda_function_url)
curl -X POST $FUNCTION_URL
```

### Paso 5: Ver Logs

```bash
# En tiempo real
aws logs tail /aws/lambda/juanmgart-duckdb-lambda --follow

# Últimos 10 minutos
aws logs tail /aws/lambda/juanmgart-duckdb-lambda --since 10m
```

## 🎯 Comandos Útiles

### Desarrollo Local

```bash
# Probar función localmente
python3 src/lambda_handler.py

# Ejecutar tests
make test

# Verificar calidad de código
make lint

# Formatear código
make format
```

### Gestión de Infraestructura

```bash
# Ver outputs de Terraform
cd terraform && terraform output

# Ver estado de recursos
cd terraform && terraform state list

# Destruir infraestructura
./destroy.sh
# o
cd terraform && terraform destroy
```

### Monitoreo

```bash
# Ver métricas en CloudWatch
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=juanmgart-duckdb-lambda \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Ver errores recientes
aws logs filter-pattern ERROR \
  --log-group-name /aws/lambda/juanmgart-duckdb-lambda \
  --start-time $(date -u -d '1 hour ago' +%s)000
```

## 📊 Respuesta Esperada

Al invocar la función, deberías recibir algo como:

```json
{
  "statusCode": 200,
  "body": {
    "message": "DuckDB query executed successfully",
    "duckdb_version": "v0.9.2",
    "data": [
      {"id": 1, "name": "Lambda", "value": 100.5},
      {"id": 2, "name": "DuckDB", "value": 200.75},
      {"id": 3, "name": "AWS", "value": 300.25}
    ],
    "rows_returned": 3
  }
}
```

## 🔧 Personalización Rápida

### Cambiar región de AWS

```bash
# En terraform.tfvars
aws_region = "us-west-2"
```

### Aumentar memoria/timeout

```bash
# En terraform.tfvars
lambda_memory_size = 1024
lambda_timeout     = 120
```

### Deshabilitar Function URL

```bash
# En terraform.tfvars
enable_function_url = false
```

## ❓ Problemas Comunes

### Error: "No credentials found"

```bash
# Configurar AWS CLI
aws configure
```

### Error: "Terraform not found"

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Error: "Access Denied"

Verifica que tu usuario AWS tiene permisos para:
- Lambda
- IAM
- CloudWatch Logs

## 📚 Siguiente Pasos

1. Lee el [README completo](README.md) para más detalles
2. Revisa [EXAMPLES.md](EXAMPLES.md) para más ejemplos de invocación
3. Lee [CONTRIBUTING.md](CONTRIBUTING.md) si quieres contribuir
4. Modifica `src/lambda_handler.py` para tus propios casos de uso

## 🗑️ Limpieza

Cuando termines de probar:

```bash
# Destruir toda la infraestructura
./destroy.sh

# Confirmar que todo fue eliminado
cd terraform && terraform state list
```

## 💡 Tips

- La primera ejecución puede tardar ~1 minuto mientras Terraform descarga providers
- Los logs de Lambda están en CloudWatch con retención de 7 días por defecto
- La Function URL es pública por defecto - considera agregar autenticación para producción
- DuckDB se ejecuta en memoria, los datos no persisten entre invocaciones

---

¿Problemas? Abre un [issue en GitHub](https://github.com/jgarteag/juanmgart-lambda-duckdb/issues)
