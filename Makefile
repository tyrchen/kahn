CHECK=\033[32m✔\033[39m
DONE="\n${CHECK} Done.\n"

deploy1:
	@echo "\nDeploy Kahn..."
	@ssh -t jcnrd.us "cd deployment/kahn; make deploy;"
	@echo DONE

deploy:
	@echo "\nDeploy kahn to the jcnrd.us server."
	git pull
	npm install
	sudo sucopy -r _deploy/etc/. /etc/.
	sudo supervisorctl reread
	sudo supervisorctl update
	sudo supervisorctl restart kahn
	sudo /etc/init.d/nginx restart
