.DEFAULT_GOAL := help
.PHONY: update

###################################################################################################
## SCRIPTS
###################################################################################################

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([\w-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		line = '{: <20} {}'.format(target, help)
		line = re.sub(r'^({})'.format(target), '\033[96m\\1\033[m', line)
		print(line)
endef

###################################################################################################
## VARIABLES
###################################################################################################

export PRINT_HELP_PYSCRIPT
export PYTHON=python

###################################################################################################
## GENERAL COMMANDS
###################################################################################################

help: ## show this message
	@$(PYTHON) -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


terraform-lint: ## lint terraform code
	( terraform fmt -recursive )
	( tflint . )


lambda-lint: ## lint lambda code
	( cd lambda && yarn lint )


build: ## zips the source code for our lambda functions into the root directory
	( cd lambda && yarn install )
	( cd lambda && yarn build )
	( cd lambda && yarn install --production )
	( cd lambda && rm ../lambda.zip 2>/dev/null ; zip -rq ../lambda.zip . )