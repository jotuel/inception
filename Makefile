all:
	docker compose -f srcs/docker-compose.yml up -d --build
mariadb:
	docker compose -f srcs/docker-compose.yml up --build mariadb
wordpress:
	docker compose -f srcs/docker-compose.yml create --build wordpress
nginx:
	mkcert jtuomi.hive.fi && mv jtuomi.hive.fi* srcs/requirements/secrets/
	docker compose -f srcs/docker-compose.yml create --build nginx
re: clean all

clean:
	docker compose -f srcs/docker-compose.yml down -v --remove-orphans
	docker builder prune -af
	docker image prune -af
	docker volume prune -af

.PHONY: all, build, re, clean
