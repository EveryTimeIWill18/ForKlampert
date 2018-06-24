
VE ?= ./ve
REQUIREMENTS ?= requirements.txt
PIP ?= $(VE)/bin/pip
WHEEL_VERSION ?= 0.31.0
REMOTE_DEPLOY_ROOT ?= /home/mhait/CallTraceAttempts/


create:
	rm -rf $(VE)
	python3 -m venv $(VE)
	$(PIP) install wheel==$(WHEEL_VERSION)
	$(PIP) install --use-wheel --requirement $(REQUIREMENTS)


settings:
	svn export --username $(GIT_USERNAME) --password $(GIT_PASSWORD) --non-interactive --force https://github.com/mhanyc/salt_state/trunk/apps/CallTraceAttempts/db_config.ini

deploy:
	@if test -z "$(REMOTE_HOST)"; then echo "REMOTE_HOST is not set: make deploy REMOTE_HOST=username@server.aws.mhaofnyc.org"; exit 1; fi
	@echo "rsynch'ing project to $$REMOTE_HOST"
	rsync -e "ssh -o StrictHostKeyChecking=no -i $(SSH_KEY)" -a -z -C --delete --verbose --exclude 've' --exclude 'output' . $(REMOTE_HOST):$(REMOTE_DEPLOY_ROOT)
	ssh -i $(SSH_KEY) $(REMOTE_HOST) "cd $(REMOTE_DEPLOY_ROOT); make create;"

deploy_local:
	@if test -z "$(REMOTE_HOST)"; then echo "REMOTE_HOST is not set: make deploy REMOTE_HOST=username@server.aws.mhaofnyc.org"; exit 1; fi
	@echo "rsynch'ing project to $$REMOTE_HOST"
	rsync -a -z -C --delete --verbose --exclude 've' --exclude 'output' . $(REMOTE_HOST):$(REMOTE_DEPLOY_ROOT)
	ssh $(REMOTE_HOST) "cd $(REMOTE_DEPLOY_ROOT); make create;"

test:
	$(VE)/bin/python3 -m tests.test_call_trace_update

clean:
	rm -rf ve
