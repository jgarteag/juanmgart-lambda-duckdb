import json

def lambda_handler(event, context):
    """
    Lambda function handler - placeholder para DuckDB integration
    """
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'event': event
        })
    }