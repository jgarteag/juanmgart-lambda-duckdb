.PHONY: help install install-dev test lint format clean deploy destroy validate

help:  ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install:  ## Install production dependencies
	pip install -r requirements.txt

install-dev:  ## Install development dependencies
	pip install -r requirements.txt -r requirements-dev.txt

test:  ## Run unit tests
	python3 -m pytest tests/ -v --cov=src --cov-report=term-missing

lint:  ## Run linting checks
	flake8 src/ tests/ --max-line-length=100
	mypy src/ --ignore-missing-imports

format:  ## Format code with black
	black src/ tests/

clean:  ## Clean up temporary files
	rm -rf __pycache__ .pytest_cache .mypy_cache .coverage
	rm -rf src/__pycache__ tests/__pycache__
	rm -rf lambda/ *.zip
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete

deploy:  ## Deploy infrastructure with Terraform
	./deploy.sh

destroy:  ## Destroy infrastructure
	./destroy.sh

validate:  ## Validate Terraform configuration
	cd terraform && terraform validate

local-test:  ## Run Lambda function locally
	python3 src/lambda_handler.py
