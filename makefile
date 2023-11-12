# Makefile

.PHONY: setup-aws-creds
setup-aws-creds:
	@echo "Setting up AWS credentials..."
	@mkdir -p ~/.aws
	@echo "[tutorial-terraform-profile]" > ~/.aws/credentials
	@echo "aws_access_key_id = $(AWS_ACCESS_KEY_ID)" >> ~/.aws/credentials
	@echo "aws_secret_access_key = $(AWS_SECRET_ACCESS_KEY)" >> ~/.aws/credentials

.PHONY: apply
apply: setup-aws-creds
	terraform apply

.PHONY: plan
plan: setup-aws-creds
	terraform plan
