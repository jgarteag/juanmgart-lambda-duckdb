"""
Unit tests for Lambda DuckDB handler.

This file contains tests for the Lambda function that uses DuckDB.
Run with: pytest test_lambda_handler.py
"""

import json
import unittest
from unittest.mock import patch, MagicMock
import sys
import os

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

# Mock duckdb for testing without installation
sys.modules['duckdb'] = MagicMock()

from lambda_handler import lambda_handler


class TestLambdaHandler(unittest.TestCase):
    """Test cases for Lambda handler."""

    @patch('lambda_handler.duckdb')
    def test_lambda_handler_success(self, mock_duckdb):
        """Test successful execution of lambda handler."""
        # Setup mock
        mock_con = MagicMock()
        mock_duckdb.connect.return_value = mock_con
        mock_con.execute.return_value.fetchall.return_value = [
            (1, 'Lambda', 100.50),
            (2, 'DuckDB', 200.75),
            (3, 'AWS', 300.25)
        ]
        mock_con.execute.return_value.fetchone.return_value = ('v0.9.2',)
        
        # Call handler
        event = {}
        context = None
        response = lambda_handler(event, context)
        
        # Assertions
        self.assertEqual(response['statusCode'], 200)
        body = json.loads(response['body'])
        self.assertEqual(body['message'], 'DuckDB query executed successfully')
        self.assertEqual(len(body['data']), 3)
        self.assertEqual(body['rows_returned'], 3)
        self.assertIn('duckdb_version', body)
        
    @patch('lambda_handler.duckdb')
    def test_lambda_handler_error(self, mock_duckdb):
        """Test error handling in lambda handler."""
        # Setup mock to raise exception
        mock_duckdb.connect.side_effect = Exception("Database connection error")
        
        # Call handler
        event = {}
        context = None
        response = lambda_handler(event, context)
        
        # Assertions
        self.assertEqual(response['statusCode'], 500)
        body = json.loads(response['body'])
        self.assertEqual(body['message'], 'Error executing DuckDB query')
        self.assertIn('error', body)
        
    @patch('lambda_handler.duckdb')
    def test_database_operations(self, mock_duckdb):
        """Test that database operations are called correctly."""
        # Setup mock
        mock_con = MagicMock()
        mock_duckdb.connect.return_value = mock_con
        mock_con.execute.return_value.fetchall.return_value = []
        mock_con.execute.return_value.fetchone.return_value = ('v0.9.2',)
        
        # Call handler
        event = {}
        context = None
        lambda_handler(event, context)
        
        # Verify database operations
        self.assertTrue(mock_duckdb.connect.called)
        self.assertTrue(mock_con.execute.called)
        self.assertTrue(mock_con.close.called)


if __name__ == '__main__':
    unittest.main()
