"""
AWS Lambda handler for DuckDB operations.

This Lambda function demonstrates hands-on usage of DuckDB in a serverless environment.
"""

import json
import duckdb
import tempfile
import os
from typing import Dict, Any


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    AWS Lambda handler function that demonstrates DuckDB usage.
    
    Args:
        event: Lambda event object containing request data
        context: Lambda context object
        
    Returns:
        Response object with statusCode and body
    """
    try:
        # Create a temporary DuckDB database
        with tempfile.TemporaryDirectory() as tmpdir:
            db_path = os.path.join(tmpdir, 'temp.duckdb')
            
            # Connect to DuckDB
            con = duckdb.connect(db_path)
            
            # Example: Create a sample table
            con.execute("""
                CREATE TABLE IF NOT EXISTS sample_data (
                    id INTEGER,
                    name VARCHAR,
                    value DECIMAL(10,2)
                )
            """)
            
            # Insert sample data
            con.execute("""
                INSERT INTO sample_data VALUES 
                (1, 'Lambda', 100.50),
                (2, 'DuckDB', 200.75),
                (3, 'AWS', 300.25)
            """)
            
            # Query the data
            result = con.execute("SELECT * FROM sample_data ORDER BY id").fetchall()
            
            # Convert to list of dictionaries for JSON response
            columns = ['id', 'name', 'value']
            data = [dict(zip(columns, row)) for row in result]
            
            # Get DuckDB version info
            version = con.execute("SELECT version()").fetchone()[0]
            
            con.close()
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'DuckDB query executed successfully',
                    'duckdb_version': version,
                    'data': data,
                    'rows_returned': len(data)
                })
            }
            
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error executing DuckDB query',
                'error': str(e)
            })
        }


def local_test():
    """Function to test the handler locally."""
    event = {}
    context = None
    
    response = lambda_handler(event, context)
    print(json.dumps(json.loads(response['body']), indent=2))


if __name__ == "__main__":
    local_test()
