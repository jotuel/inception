*Inception is a containerized LAMP-stack project switching apache to nginx and MySQL to MariaDB*

You'll need root access (administrator priviliges) on the system. Mostly to use port 443.

## Usage

You'll need to add correct secrets before starting. Those can be found from `/srcs/docker-compose.yml`.

Calling `make` in root folder builds and starts Docker container.

`make clean` completely removes everything installed by `make`.

Once its up you can go to the domain you configured using https and start modifying the site.

## How it works

It has a compose file that uses three Dockerfiles to build start mariadb, wordpress and nginx.

Those can communicate and share some files inside the container network & volumes. 

Only nginx and port 443 is exposed outside of the container.

It uses self-signed certs so it is not production grade.
