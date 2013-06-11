CHECK=\033[32m✔\033[39m
DONE="\n$(CHECK) Done.\n"

SERVER=jcnrd.us
PROJECT=kahn
PATH=deployment/$(PROJECT)
SUPERVISORCTL=/usr/bin/supervisorctl
SUCOPY=/bin/sucopy
SSH=/usr/bin/ssh
ECHO=/bin/echo
NPM=/usr/local/bin/npm

deploy1:
	@$(ECHO) "\nDeploy $(PROJECT)..."
	@$(SSH) -t $(SERVER) "echo Deploy $(PROJECT) to the $(SERVER) server.; cd $(PATH); git pull; make deploy;"
	@$(ECHO) "Successfully deployed to $(SERVER)"

dependency:
	@$(ECHO) echo "Install project dependencies..."
	$(NPM) install

configuration:
	@$(ECHO) "Update configuration..."
	sudo $(SUCOPY) -r _deploy/etc/. /etc/.

supervisor:
	@$(ECHO) "Update supervisor configuration..."
	sudo $(SUPERVISORCTL) reread
	sudo $(SUPERVISORCTL) update
	@$(ECHO) "Restart $(PROJECT)..."
	sudo $(SUPERVISORCTL) restart $(PROJECT)

nginx:
	@$(ECHO) "Restart nginx..."
	sudo /etc/init.d/nginx restart

deploy: dependency configuration supervisor nginx
	@$(ECHO) $(DONE)
