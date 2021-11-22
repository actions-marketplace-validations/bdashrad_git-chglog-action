FROM docker.io/alpine:latest

RUN apk add --update --no-cache git jq

COPY ["src", "/src/"]

ENTRYPOINT [ "/src/main.sh" ]
