use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
# Configure your database
config :cercleApi, CercleApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "YOUR_USERNAME",
  password: "YOUR_PASSWORD",
  database: "",
  hostname: "localhost",
  pool_size: 10

config :arc,
  bucket: "YOUR_AWS_BUCKET",
  virtual_host: true

config :ex_aws,
  access_key_id: "YOUR_KEY_ID",
  secret_access_key: "YOUR_SECRET_KEY",
  region: "YOUR_REGION"

config :cercleApi, basic_auth: [
    username: "admin",
    password: "admin",
    realm: "Admin Area"
  ]

config :mailman,
  relay: "smtp.postmarkapp.com",                 
  port: 587,
  username: "SMTP_LOGIN",
  password: "SMTP_PASSWORD",
  tls: :always
