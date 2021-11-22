FROM docker.io/alpine:latest

COPY entrypoint.sh /entrypoint.sh
RUN apk add --update --no-cache git jq

COPY ["src", "/src/"]

ENTRYPOINT [ "/src/main.sh" ]
