# juanmgart-lambda-duckdb

Proyecto hands-on para desarrollo de una función AWS Lambda utilizando DuckDB, con infraestructura como código (IaC) usando Terraform.

## 📋 Descripción

Este proyecto demuestra cómo implementar una función Lambda de AWS que utiliza DuckDB para operaciones de base de datos analíticas en un entorno serverless. La infraestructura se gestiona completamente con Terraform.

## 🏗️ Arquitectura

- **AWS Lambda**: Función serverless que ejecuta consultas DuckDB
- **DuckDB**: Base de datos analítica embebida
- **Terraform**: Infraestructura como código para deployment
- **CloudWatch**: Logging y monitoreo
- **Lambda Function URL** (opcional): Endpoint HTTP para invocar la función

## 📁 Estructura del Proyecto

```
.
├── src/
│   └── lambda_handler.py          # Handler de la función Lambda
├── terraform/
│   ├── main.tf                     # Configuración principal de Terraform
│   ├── variables.tf                # Definición de variables
│   ├── outputs.tf                  # Outputs de Terraform
│   └── terraform.tfvars.example    # Ejemplo de variables
├── requirements.txt                # Dependencias Python
└── README.md                       # Documentación
```

## 🚀 Prerequisitos

- Python 3.11+
- Terraform >= 1.0
- AWS CLI configurado con credenciales
- Cuenta de AWS

## 💻 Instalación Local

### 1. Clonar el repositorio

```bash
git clone https://github.com/jgarteag/juanmgart-lambda-duckdb.git
cd juanmgart-lambda-duckdb
```

### 2. Instalar dependencias Python

```bash
pip install -r requirements.txt
```

### 3. Probar la función localmente

```bash
python src/lambda_handler.py
```

## ☁️ Deployment con Terraform

### 1. Configurar variables

Copiar el archivo de ejemplo y editarlo con tus valores:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus configuraciones
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Planificar el deployment

```bash
terraform plan
```

### 4. Aplicar la infraestructura

```bash
terraform apply
```

### 5. Obtener outputs

```bash
terraform output
```

## 🧪 Uso de la Función Lambda

### Invocar desde AWS CLI

```bash
aws lambda invoke \
  --function-name juanmgart-duckdb-lambda \
  --payload '{}' \
  response.json

cat response.json
```

### Invocar desde Function URL (si está habilitada)

```bash
curl -X POST <FUNCTION_URL>
```

La URL se obtiene del output de Terraform: `terraform output lambda_function_url`

## 📊 Ejemplo de Respuesta

```json
{
  "message": "DuckDB query executed successfully",
  "duckdb_version": "v0.9.2",
  "data": [
    {"id": 1, "name": "Lambda", "value": 100.5},
    {"id": 2, "name": "DuckDB", "value": 200.75},
    {"id": 3, "name": "AWS", "value": 300.25}
  ],
  "rows_returned": 3
}
```

## 🔧 Configuración de Variables Terraform

| Variable | Descripción | Default |
|----------|-------------|---------|
| `aws_region` | Región de AWS | `us-east-1` |
| `environment` | Entorno (dev/staging/prod) | `dev` |
| `function_name` | Nombre de la función Lambda | `juanmgart-duckdb-lambda` |
| `lambda_timeout` | Timeout en segundos | `60` |
| `lambda_memory_size` | Memoria en MB | `512` |
| `log_retention_days` | Retención de logs | `7` |
| `enable_function_url` | Habilitar URL de función | `true` |

## 🗑️ Destruir Infraestructura

```bash
cd terraform
terraform destroy
```

## 📝 Notas Técnicas

- DuckDB corre completamente en memoria o en almacenamiento temporal de Lambda
- La función utiliza un directorio temporal para la base de datos
- Los logs se almacenan en CloudWatch Logs
- La configuración actual permite 512MB de memoria y 60 segundos de timeout

## 🔐 Seguridad

- La función Lambda tiene permisos mínimos (AWSLambdaBasicExecutionRole)
- La Function URL está configurada sin autenticación por defecto (cambiar en producción)
- Considerar agregar API Gateway con autenticación para producción

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia especificada en el archivo LICENSE.

## 👤 Autor

Juan M. García - [@jgarteag](https://github.com/jgarteag)