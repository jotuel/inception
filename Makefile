all:
	docker-compose -f srcs/docker-compose.yml up
build:
	docker-compose -f srcs/docker-compose.yml build
clean:
	docker-compose -f srcs/docker-compose.yml rm
