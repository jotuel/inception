FROM alpine:3

RUN apk update && apk upgrade && apk add nginx
COPY ./conf/nginx.conf.conf /etc/nginx/conf.d/nginx.conf
CMD ''
