FROM msoap/shell2http as shell2http

FROM alpine:3.9

RUN apk add --no-cache openssh-client
RUN mkdir /code
WORKDIR /code

COPY --from=shell2http /app/shell2http /usr/local/bin/shell2http
COPY ssh-runner.sh .
COPY remote-hello.sh .
COPY entrypoint.sh .


EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]
#ENTRYPOINT ["shell2http"]
#CMD ["-export-vars=SSH_USERNAME,SSH_SERVER", "/", "/code/ssh-runner.sh"]
