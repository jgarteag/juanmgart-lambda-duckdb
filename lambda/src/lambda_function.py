import json
import boto3
from urllib.parse import unquote_plus

def lambda_handler(event, context):
    """
    Procesa archivos CSV desde eventos SNS o EventBridge
    """
    
    try:
        print(f"=== INICIO LAMBDA ===")
        print(f"Evento recibido: {json.dumps(event, indent=2)}")
        
        bucket = None
        key = None
        
        # Verificar si es evento SNS o EventBridge
        if 'Records' in event:
            print("Detectado evento SNS")
            # Evento SNS
            for record in event['Records']:
                sns_message = json.loads(record['Sns']['Message'])
                bucket = sns_message['Records'][0]['s3']['bucket']['name']
                key = unquote_plus(sns_message['Records'][0]['s3']['object']['key'])
        elif 'detail' in event and 'bucket' in event['detail']:
            print("Detectado evento EventBridge")
            # Evento EventBridge
            bucket = event['detail']['bucket']['name']
            key = event['detail']['object']['key']
        else:
            print(f"Formato de evento no reconocido. Claves disponibles: {list(event.keys())}")
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Formato de evento no reconocido',
                    'event_keys': list(event.keys()),
                    'event': event
                })
            }
            
        print(f"Bucket: {bucket}")
        print(f"Key: {key}")
        print(f"Procesando archivo: s3://{bucket}/{key}")
        
        # Procesar archivo (versión simple)
        result = process_csv_simple(bucket, key)
        
        print("=== PROCESAMIENTO EXITOSO ===")
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Archivo CSV procesado exitosamente!',
                'file': f's3://{bucket}/{key}',
                'processed_rows': result['rows'],
                'selected_columns': result['columns'],
                'stats': result['stats'],
                'sample_data': result['sample_data']
            })
        }
            
    except Exception as e:
        print(f"=== ERROR EN LAMBDA ===")
        print(f"Error procesando archivo: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'type': type(e).__name__
            })
        }

def process_csv_simple(bucket, key):
    """
    Procesa archivos CSV de forma simple (sin pandas)
    """
    
    # Cliente S3 para leer el archivo
    s3_client = boto3.client('s3')
    
    # Leer archivo CSV desde S3
    print(f"Leyendo archivo desde S3: {bucket}/{key}")
    response = s3_client.get_object(Bucket=bucket, Key=key)
    csv_content = response['Body'].read().decode('utf-8')
    
    # Procesar CSV manualmente
    print("Procesando CSV manualmente...")
    lines = csv_content.strip().split('\n')
    headers = lines[0].split(',')
    
    print(f"Headers encontrados: {headers}")
    print(f"Total de líneas: {len(lines)}")
    
    # Contar filas de datos (excluyendo header)
    data_rows = len(lines) - 1
    
    # Estadísticas simples
    stats = {
        'total_rows': data_rows,
        'headers': headers,
        'file_size_bytes': len(csv_content)
    }
    
    # Muestra de datos (primeras 2 líneas)
    sample_data = []
    for i in range(1, min(3, len(lines))):
        row_data = lines[i].split(',')
        sample_data.append(dict(zip(headers, row_data)))
    
    print(f"Procesamiento completado. Filas procesadas: {data_rows}")
    
    return {
        'rows': data_rows,
        'columns': headers,
        'stats': stats,
        'sample_data': sample_data
    }