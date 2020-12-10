start: set-executable 
	infra/scripts/start.sh

deploy: set-executable 
	infra/scripts/deploy.sh

teardown: set-executable 
	infra/scripts/delete.sh

set-executable:
	chmod +x infra/scripts/*.sh
