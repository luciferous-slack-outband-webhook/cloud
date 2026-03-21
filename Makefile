SHELL = /usr/bin/env bash -xeuo pipefail

format: \
	fmt-terraform \
	fmt-python

fmt-terraform: \
	fmt-terraform-root \
	fmt-terraform-module-common \
	fmt-terraform-module-events-slack-webhook-destination \
	fmt-terraform-module-lambda-function \
	fmt-terraform-module-lambda-function-basic

fmt-terraform-root:
	terraform fmt

fmt-terraform-module-common:
	cd terraform_modules/common; \
	terraform fmt

fmt-terraform-module-events-slack-webhook-destination:
	cd terraform_modules/events_slack_webhook_destination; \
	terraform fmt

fmt-terraform-module-lambda-function:
	cd terraform_modules/lambda_function; \
	terraform fmt

fmt-terraform-module-lambda-function-basic:
	cd terraform_modules/lambda_function_basic; \
	terraform fmt

fmt-python:
	uv run isort src/ tests/
	uv run black src/ tests/

lint: \
	lint-terraform \
	lint-python

lint-terraform: \
	lint-terraform-root \
	lint-terraform-module-common \
	lint-terraform-module-events-slack-webhook-destination \
	lint-terraform-module-lambda-function \
	lint-terraform-module-lambda-function-basic

lint-terraform-root:
	terraform fmt -check

lint-terraform-module-common:
	cd terraform_modules/common; \
	terraform fmt -check

lint-terraform-module-events-slack-webhook-destination:
	cd terraform_modules/events_slack_webhook_destination; \
	terraform fmt -check

lint-terraform-module-lambda-function:
	cd terraform_modules/lambda_function; \
	terraform fmt -check

lint-terraform-module-lambda-function-basic:
	cd terraform_modules/lambda_function_basic; \
	terraform fmt -check

lint-python:
	uv run isort -c src/ tests/
	uv run black --check src/ tests/

test-unit:
	uv run pytest -vv tests/unit

compose-up:
	docker compose up -d
	sleep 5

compose-down:
	docker compose down

terraform-init:
	terraform init \
		-backend-config="bucket=$$BACKEND_S3_BUCKET" \
		-backend-config="key=$$BACKEND_S3_KEY" \
		-backend-config="region=$$BACKEND_REGION"

.PHONY: \
	format \
	fmt-terraform \
	fmt-terraform-root \
	fmt-terraform-module-common \
	fmt-python \
	lint \
	lint-terraform \
	lint-terraform-root \
	lint-terraform-module-common \
	lint-python \
	test-unit \
	compose-up \
	compose-down \
	terraform-init
