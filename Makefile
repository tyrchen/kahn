CHECK=\033[32m✔\033[39m
DONE="\n$(CHECK) Done.\n"

SERVER=jcnrd.us
PROJECT=kahn
SUPERVISORCTL=/usr/bin/supervisorctl
SUCOPY=/bin/sucopy

deploy1:
	@echo "\nDeploy $(PROJECT)..."
	@ssh -t $(SERVER) "cd deployment/$(PROJECT); make deploy;"
	@echo $(DONE)

deploy:
	@echo "\nDeploy kahn to the $(SERVER) server."
	@echo "Retrieve latest code..."
	git pull
	@echo "Install nodejs dependencies..."
	npm install
	@echo "Update configuration..."
	sudo $(SUCOPY) -r _deploy/etc/. /etc/.
	@echo "Update supervisor configuration..."
	sudo $(SUPERVISORCTL) reread
	sudo $(SUPERVISORCTL) update
	@echo "Restart $(PROJECT)..."
	sudo $(SUPERVISORCTL) restart $(PROJECT)
	@echo "Restart nginx..."
	sudo /etc/init.d/nginx restart
	@echo $(DONE)
