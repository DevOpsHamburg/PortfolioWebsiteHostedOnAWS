.PHONY: help deploy-website
.DEFAULT_GOAL := help

export AWS_PROFILE=org
export AWS_DEFAULT_REGION=eu-central-1


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


deploy-website-resources: ## deploy website resources
	aws cloudformation deploy \
		--profile $(AWS_PROFILE) \
		--stack-name organization-website \
		--template-file cloudformation/website.yaml

deploy-website-content: ## deploy website content
	cd website; jekyll build
	ACCOUNT_ID=$$(aws --profile $(AWS_PROFILE) sts get-caller-identity  --query Account --output text); \
	aws --profile $(AWS_PROFILE) s3 cp --recursive website/_site s3://organization-website-$$ACCOUNT_ID
