require 'pg'

if ENV["RACK_ENV"] == 'production'
  conn = PG.connect(
    dbname: ENV["POSTGRES_DB"],
    host: ENV["POSTGRES_HOST"],
    password: ENV["POSTGRES_PASS"],
    user: ENV["POSTGRES_USER"]
  )
else
  conn = PG.connect(dbname: "wiki_test")
end

conn.exec("INSERT INTO users (user_name, user_password, user_email) VALUES (
    'Shawn',
    'Password1',
    'shawn@bigcat.io'
  )"
)