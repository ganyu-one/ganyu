import Config

if config_env() == :prod do
  config :ganyu,
    port: String.to_integer(System.get_env("PORT", "8080")),
    proxy_path: System.get_env("GANYU_PROXY", "https://pximg.pxseu.com"),
    postgres_hostname:
      System.get_env(
        "GANYU_POSTGRES_HOSTNAME",
        "localhost"
      ),
    postgres_username:
      System.get_env(
        "GANYU_POSTGRES_USERNAME",
        "postgres"
      ),
    postgres_password:
      System.get_env(
        "GANYU_POSTGRES_PASSWORD",
        "postgres"
      ),
    postres_database:
      System.get_env(
        "GANYU_POSTGRES_DATABASE",
        "ganyu"
      )
end
