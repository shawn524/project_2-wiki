module Wiki
  class Server < Sinatra::Base

    enable :sessions

    def current_user
      if session["user_id"]
        @user ||= conn.exec_params("SELECT * FROM users WHERE id = $1", [session["user_id"].first])
      else
        # THE USER IS NOT LOGGED IN
        {}
      end
    end

    get "/" do
      erb :index
    end

    get "/signup" do
      erb :new_user
    end

    post "/signup" do
      user_name = params["user_name"]
      password = BCrypt::Password.create(params["password"])
      email = params["email"]

      conn.exec_params("INSERT INTO users (user_name, user_password, user_email) VALUES ($1,$2,$3);",[user_name, passwd, email])
      redirect "/"
    end

    get "/login" do
      erb :login
    end

    post "/login" do

    end

    get "/new_article" do
      erb :new_article
    end

    post "/new_article" do
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      md = markdown.render(params["new_article"])

      conn.exec_params("INSERT INTO revision (rev_text) VALUES ($1);", [md])
    end


    def conn
      if ENV["RACK_ENV"] == 'production'
        PG.connect(
          dbname: ENV["POSTGRES_DB"],
          host: ENV["POSTGRES_HOST"],
          password: ENV["POSTGRES_PASS"],
          user: ENV["POSTGRES_USER"]
        )
      else
        PG.connect(dbname: "wiki_test")
      end
    end
  end
end
