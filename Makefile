.PHONY: help deploy-resources deploy-content
.DEFAULT_GOAL := help

export AWS_PROFILE = org
export AWS_DEFAULT_REGION = eu-central-1
export HOSTED_ZONE_NAME = devops-hamburg.de
export SERVICE = org-website

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


deploy-resources: ## deploy website resources
	echo "Deploy Certificate..."
	aws cloudformation deploy \
		--profile $(AWS_PROFILE) \
		--stack-name org-certificate \
		--region us-east-1 \
		--template-file cloudformation/certificate.yaml \
		--parameter-overrides HostedZone=$(HOSTED_ZONE) \
		--tags service=$(SERVICE) || true

	echo "Deploy Service..."
	CERTIFICATE_ARN=$$(aws --profile $(AWS_PROFILE) --region us-east-1 cloudformation describe-stacks \
		--stack-name org-certificate \
		--query Stacks[0].Outputs | \
			jq '.[] | select(.OutputKey=="CertificateArn") | .OutputValue' -r); \
	HOSTED_ZONE_ID=$$(aws --profile $(AWS_PROFILE) --region $(AWS_DEFAULT_REGION) route53 list-hosted-zones | jq '.HostedZones[] | select (.Name == "'$(HOSTED_ZONE_NAME)'.") | .Id' -r | cut -d'/' -f3); \
	aws cloudformation deploy \
		--profile $(AWS_PROFILE) \
		--stack-name org-website \
		--template-file cloudformation/website.yaml \
		--parameter-overrides Service=$(SERVICE) \
		                      HostedZoneId=$$HOSTED_ZONE_ID \
		                      HostedZoneName=$(HOSTED_ZONE_NAME) \
		                      CertificateArn=$$CERTIFICATE_ARN \
		--tags service=$(SERVICE)

deploy-content: ## deploy website content
	cd website; bundle exec jekyll build
	ACCOUNT_ID=$$(aws --profile $(AWS_PROFILE) sts get-caller-identity  --query Account --output text); \
	aws --profile $(AWS_PROFILE) s3 cp --recursive website/_site s3://org-website-$$ACCOUNT_ID
