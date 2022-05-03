BUILD_ENV:=prod

dev:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	iex -S mix

build:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	MIX_ENV=${BUILD_ENV} mix compile
	MIX_ENV=${BUILD_ENV} mix release

install:
	rm -rf /opt/ganyu
	cp ./_build/prod/rel/ganyu/ /opt/ganyu -r
	cp ./ganyu.service /etc/systemd/system/
	systemctl daemon-reload
