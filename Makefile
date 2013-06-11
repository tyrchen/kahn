CHECK=\033[32m✔\033[39m
DONE="\n$(CHECK) Done.\n"

SERVER=jcnrd.us
PROJECT=kahn
PATH=deployment/$(PROJECT)
SUPERVISORCTL=/usr/bin/supervisorctl
SUCOPY=/bin/sucopy
SSH=/usr/bin/ssh
ECHO=/bin/echo -e
NPM=/usr/local/bin/npm
SUDO=/usr/bin/sudo

deploy1:
	@$(SSH) -t $(SERVER) "echo Deploy $(PROJECT) to the $(SERVER) server.; cd $(PATH); git pull; make deploy;"
	@$(ECHO) "Successfully deployed to $(SERVER)"

dependency:
	@$(ECHO) echo "Install project dependencies..."
	$(NPM) install

configuration:
	@$(ECHO) "Update configuration..."
	$(SUDO) $(SUCOPY) -r _deploy/etc/. /etc/.

supervisor:
	@$(ECHO) "Update supervisor configuration..."
	$(SUDO) $(SUPERVISORCTL) reread
	$(SUDO) $(SUPERVISORCTL) update
	@$(ECHO) "Restart $(PROJECT)..."
	$(SUDO) $(SUPERVISORCTL) restart $(PROJECT)

nginx:
	@$(ECHO) "Restart nginx..."
	$(SUDO) /etc/init.d/nginx restart

deploy: dependency configuration supervisor nginx
	@$(ECHO) $(DONE)
