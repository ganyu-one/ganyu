FROM elixir:1.13-alpine AS build

ENV MIX_ENV=prod

WORKDIR /app

RUN apk add --no-cache git

# get deps first so we have a cache
ADD mix.exs mix.lock /app/
RUN \
	cd /app && \
	mix local.hex --force && \
	mix local.rebar --force && \
	mix deps.get

# then make a release build
ADD . /app/
RUN \
	mix compile && \
	mix release

FROM elixir:1.13-alpine

COPY --from=build /app/_build/prod/rel/ganyu /opt/ganyu

CMD [ "/opt/ganyu/bin/ganyu", "start" ]