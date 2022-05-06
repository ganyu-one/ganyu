BUILD_ENV:=prod
APP_NAME:=ganyu

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
	yes | MIX_ENV=${BUILD_ENV} mix release 

uninstall:
	systemctl stop ${APP_NAME}.service || true
	systemctl disable ${APP_NAME}.service || true
	rm -rf /etc/systemd/system/${APP_NAME}.service
	rm -rf /opt/${APP_NAME}

install: uninstall
	cp ./_build/prod/rel/${APP_NAME}/ /opt/${APP_NAME} -r
	cp ./${APP_NAME}.service /etc/systemd/system/
	systemctl daemon-reload

enable:
	systemctl enable ${APP_NAME}.service
	systemctl start ${APP_NAME}.service