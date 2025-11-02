# Ejemplos de Invocación de Lambda

Este documento proporciona ejemplos de cómo invocar la función Lambda con DuckDB desde diferentes clientes.

## 📋 Tabla de Contenidos

- [AWS CLI](#aws-cli)
- [Python (boto3)](#python-boto3)
- [cURL (Function URL)](#curl-function-url)
- [Node.js (AWS SDK)](#nodejs-aws-sdk)
- [Terraform Output](#terraform-output)

## AWS CLI

### Invocar la función

```bash
aws lambda invoke \
  --function-name juanmgart-duckdb-lambda \
  --payload '{}' \
  response.json

# Ver la respuesta
cat response.json | jq '.'
```

### Con payload personalizado (si se implementa)

```bash
aws lambda invoke \
  --function-name juanmgart-duckdb-lambda \
  --payload '{"query": "SELECT * FROM sample_data WHERE id > 1"}' \
  response.json
```

## Python (boto3)

```python
import boto3
import json

# Crear cliente Lambda
lambda_client = boto3.client('lambda', region_name='us-east-1')

# Invocar función
response = lambda_client.invoke(
    FunctionName='juanmgart-duckdb-lambda',
    InvocationType='RequestResponse',
    Payload=json.dumps({})
)

# Leer respuesta
payload = json.loads(response['Payload'].read())
print(json.dumps(payload, indent=2))
```

## cURL (Function URL)

Si la Function URL está habilitada, puedes invocar la función con HTTP:

```bash
# Obtener la URL del output de Terraform
FUNCTION_URL=$(cd terraform && terraform output -raw lambda_function_url)

# Invocar con cURL
curl -X POST $FUNCTION_URL \
  -H "Content-Type: application/json" \
  -d '{}' | jq '.'
```

### Con datos

```bash
curl -X POST $FUNCTION_URL \
  -H "Content-Type: application/json" \
  -d '{"query": "SELECT COUNT(*) FROM sample_data"}' | jq '.'
```

## Node.js (AWS SDK)

```javascript
const { LambdaClient, InvokeCommand } = require("@aws-sdk/client-lambda");

const client = new LambdaClient({ region: "us-east-1" });

async function invokeLambda() {
  const command = new InvokeCommand({
    FunctionName: "juanmgart-duckdb-lambda",
    Payload: JSON.stringify({}),
  });

  try {
    const response = await client.send(command);
    const payload = JSON.parse(
      new TextDecoder("utf-8").decode(response.Payload)
    );
    console.log(JSON.stringify(payload, null, 2));
  } catch (error) {
    console.error("Error:", error);
  }
}

invokeLambda();
```

## Terraform Output

Para obtener la información de deployment desde Terraform:

```bash
cd terraform

# Ver todos los outputs
terraform output

# Obtener URL de la función
terraform output lambda_function_url

# Obtener ARN de la función
terraform output lambda_function_arn

# Obtener nombre del CloudWatch Log Group
terraform output cloudwatch_log_group
```

## Respuesta Esperada

La función Lambda debería devolver una respuesta similar a:

```json
{
  "statusCode": 200,
  "body": "{\"message\": \"DuckDB query executed successfully\", \"duckdb_version\": \"v0.9.2\", \"data\": [{\"id\": 1, \"name\": \"Lambda\", \"value\": 100.5}, {\"id\": 2, \"name\": \"DuckDB\", \"value\": 200.75}, {\"id\": 3, \"name\": \"AWS\", \"value\": 300.25}], \"rows_returned\": 3}"
}
```

## Monitoreo

### Ver logs en CloudWatch

```bash
# Obtener nombre del log group
LOG_GROUP="/aws/lambda/juanmgart-duckdb-lambda"

# Ver últimos logs
aws logs tail $LOG_GROUP --follow

# Ver logs de las últimas 10 minutos
aws logs tail $LOG_GROUP --since 10m
```

### Métricas de la función

```bash
# Obtener métricas de invocaciones
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=juanmgart-duckdb-lambda \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

## Testing Local

Para probar la función localmente sin AWS:

```bash
# Ejecutar directamente
python3 src/lambda_handler.py

# Con variables de entorno
ENV_VAR=value python3 src/lambda_handler.py
```

## Troubleshooting

### Error: "Module 'duckdb' not found"

Asegúrate de que las dependencias estén incluidas en el deployment package:

```bash
cd src
pip install -r ../requirements.txt -t .
zip -r ../lambda_function.zip .
```

### Error: "Function URL not enabled"

Habilita la Function URL en terraform.tfvars:

```hcl
enable_function_url = true
```

Luego aplica los cambios:

```bash
cd terraform
terraform apply
```
