DOCKER_COMPOSE?=docker-compose
INSTANCE=${CURRENT_INSTANCE}
RUN=$(DOCKER_COMPOSE) run --rm app
EXEC?=$(DOCKER_COMPOSE) exec app entrypoint.sh
CONSOLE=$(EXEC)
HTTPDUSER=$(ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1)
clear:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -v --force
	$(EXEC) rm -rf var/cache/*
	$(EXEC) rm -rf var/sessions/*
	rm -rf var/logs/*

stop:
	$(DOCKER_COMPOSE) stop

start:          ## Start docker container
	$(DOCKER_COMPOSE) up -d

exec:           ## Get your fav env (Usage: 'make exec INSTANCE=data')
	docker-compose exec web /bin/bash

restart: stop start

build:
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d
	$(DOCKER_COMPOSE) stop
	$(DOCKER_COMPOSE) start
	sudo chown -R ${USER_ID}:${GROUP_ID} .
	$(DOCKER_COMPOSE) exec -u ${USER_ID}:${GROUP_ID} web symfony new --dir=. --version=5.0
