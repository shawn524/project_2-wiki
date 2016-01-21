module Wiki
  class Server < Sinatra::Base

    enable :sessions

    def current_user
      if session["user_id"]
        @user ||= conn.exec_params("SELECT * FROM users WHERE user_id = $1", [session["user_id"]])
        # binding.pry
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

      conn.exec_params("INSERT INTO users (user_name, user_password, user_email) VALUES ($1,$2,$3);",[user_name, password, email])
      redirect "/"
    end

    get "/login" do
      erb :login
    end

    post '/login' do
      user_name = params['user_name']
      password = params['password']

      returning_user = conn.exec_params("SELECT * FROM users WHERE user_name = $1;",[user_name]).first
      # binding.pry
      if returning_user.any?
        check = BCrypt::Password.new(returning_user['user_password'])
        if check == password
          # this user_id is just a var, but now they are tagged?
          session['user_id'] = returning_user['user_id']
          session['logged_in'] = true
          session['user_name'] = returning_user['user_name']
          # binding.pry
          erb :index
        else
          erb :login
        end
      else
        erb :new_user
      end
    end

    get "/new_article" do
      erb :new_article
    end

    post "/new_article" do
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      md = markdown.render(params["new_article"])
      page_title = params["page_title"]

      conn.exec_params("INSERT INTO page (page_title) VALUES ($1);", [page_title])
      newest_page = conn.exec("SELECT * FROM page").to_a.last
      conn.exec_params("INSERT INTO revision (rev_page, rev_user, rev_user_name, rev_text) VALUES ($1, $2, $3, $4);", [newest_page["page_id"], session["user_id"], session["user_name"],md])

      erb
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
