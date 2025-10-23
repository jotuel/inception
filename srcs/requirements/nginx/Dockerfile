FROM alpine:3

RUN apk update && apk upgrade && apk add --no-cache nginx openssl bash

COPY ./conf/nginx.conf.conf /etc/nginx/http.d/nginx.conf
COPY tools/nginx.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
