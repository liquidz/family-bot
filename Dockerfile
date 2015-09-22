FROM uochan/elixir
MAINTAINER uochan

COPY . /app
WORKDIR /app
RUN mix deps.get

CMD ["/bin/sh", "/app/docker_start.sh"]
