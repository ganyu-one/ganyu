import Config

if config_env() == :prod do
  config :ganyu,
    port: String.to_integer(System.get_env("GANYU_PORT", "8080")),
    proxy_path: System.get_env("GANYU_PROXY", "https://pximg.pxseu.com")
end
