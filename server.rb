module Wiki
  class Server < Sinatra::Base

    enable :sessions

    def current_user
      @user ||= conn.exec_params("SELECT * FROM users WHERE user_id = $1", [ session[ "user_id" ] ]).first if session["user_id"]
    end

    def logged_in?
      current_user
    end

    get "/" do
      @articles = conn.exec("SELECT * FROM page").to_a
      erb :index
    end

    get "/signup" do
      erb :new_user
    end

    post "/signup" do
      user_name = params[ "user_name" ]
      password = BCrypt::Password.create(params[ "password" ])
      email = params[ "email" ]

      exist = conn.exec_params("SELECT user_name FROM users WHERE user_name = $1", [ user_name ]).first
      unless exist
        conn.exec_params("INSERT INTO users (user_name, user_password, user_email) VALUES ($1,$2,$3);",[ user_name, password, email ])
        redirect "/"
      else
        @error = true
        erb :new_user
      end
    end

    get "/logout" do
      session.delete("user_id")
      redirect "/"
    end

    get "/login" do
      erb :login
    end

    post '/login' do
      user_name = params[ 'user_name' ]
      password = params[ 'password' ]
      user = conn.exec_params("SELECT * FROM users WHERE user_name = $1;",[ user_name ]).first

      if user != nil && BCrypt::Password.new(user[ 'user_password' ]) == password
          session[ 'user_id' ] = user[ 'user_id' ]
          redirect "/"
      else
        @error = true
        erb :login
      end
    end

    get "/article/new" do
      @tags = conn.exec("SELECT * FROM tags").to_a
      erb :new_article
    end

    post "/article/new" do
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      sanitize = Sanitize.fragment( params[ "new_article" ] )
      md = markdown.render(sanitize)
      raw_text = sanitize
      page_title = Sanitize.fragment( params[ "page_title" ] )
      tag = params[ "page_tag" ]

      tag_id = conn.exec_params("SELECT tag_id FROM tags WHERE tag_name = $1;",[ tag ]).first


      exist = conn.exec_params("SELECT page_title FROM page WHERE page_title = $1", [ page_title ]).first

      unless exist
        conn.exec_params("INSERT INTO page (page_title, page_tag) VALUES ($1, $2);", [ page_title, tag_id["tag_id"] ])

        newest_page = conn.exec("SELECT * FROM page").to_a.last
        conn.exec_params("INSERT INTO revision (rev_page, rev_user, rev_user_name, rev_text, rev_markdown) VALUES ($1, $2, $3, $4, $5);", [ newest_page["page_id"], session["user_id"], current_user["user_name"], raw_text, md ])

        redirect "/article/#{newest_page[ "page_id" ]}"
      else
        @error = true
        @tags = conn.exec("SELECT * FROM tags").to_a
        erb :new_article
      end

    end

    get "/article/:id" do
      current_page = conn.exec_params("SELECT * FROM page JOIN tags ON page.page_tag = tags.tag_id WHERE page.page_id = $1;", [ params[ "id" ] ]).to_a
      all_revs = conn.exec_params("SELECT * FROM revision WHERE rev_page = $1;", [ params[ "id" ] ]).to_a
      current_rev = all_revs.last

        @id = params["id"]
        @title = current_page.first[ "page_title" ]
        @content = current_rev[ "rev_markdown" ]
        @last_edit = current_rev[ "rev_created" ].slice(0,19)
        @last_author = current_rev[ "rev_user_name" ]
        @author_id = current_rev[ "rev_user" ]
        @tag = current_page.first[ "tag_name" ]

      erb :article
    end

    get "/article/:id/edit" do
      current_page = conn.exec_params("SELECT * FROM page WHERE page_id = $1;", [ params[ "id" ] ]).to_a
      all_revs = conn.exec_params("SELECT * FROM revision WHERE rev_page = $1;", [ params[ "id" ] ]).to_a
      current_rev = all_revs.last

        @id = params["id"]
        @title = current_page.first[ "page_title" ]
        @content = current_rev[ "rev_text" ]
        @last_edit = current_rev[ "rev_created" ].slice(0,19)
        @last_author = current_rev[ "rev_user_name" ]

      erb :edit

    end

    post "/article/:id" do
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      sanitize = Sanitize.fragment( params[ "update_article" ] )
      md = markdown.render(sanitize)
      raw_text = sanitize

      @id = params["id"]

      conn.exec_params("INSERT INTO revision (rev_page, rev_user, rev_user_name, rev_text, rev_markdown) VALUES ($1, $2, $3, $4, $5);", [ @id , session["user_id"], current_user["user_name"], raw_text, md ])

      redirect "/article/#{@id}"

    end

    get "/article/:id/history" do
      current_page = conn.exec_params("SELECT * FROM page WHERE page_id = $1;", [ params[ "id" ] ]).to_a
      @all_revs = conn.exec_params("SELECT * FROM revision WHERE rev_page = $1;", [ params[ "id" ] ]).to_a
      current_rev = @all_revs.last

        @id = params["id"]
        @title = current_page.first[ "page_title" ]
        @content = current_rev[ "rev_markdown" ]
        @last_edit = current_rev[ "rev_created" ].slice(0,19)
        @last_author = current_rev[ "rev_user_name" ]

        erb :history

    end

    get "/article/tag/:name" do
      @tag = conn.exec_params("SELECT * FROM tags WHERE tag_name = $1;", [ params[ "name" ] ]).first
      @id = @tag["tag_id"].to_i
      @pages = conn.exec_params("SELECT * FROM page WHERE page_tag = $1;", [ @id ]).to_a

      erb :tags
    end

    get "/search" do
      @query = "%#{params['query']}%"
      @result = conn.exec_params("SELECT * FROM page WHERE page_title ILIKE $1;", [ @query ]).to_a

      erb :search
    end

    get "/user/:id" do
      @user = conn.exec_params("SELECT * FROM users WHERE user_id = $1;",[ params[ "id" ] ]).first
      @posts = conn.exec_params("SELECT * FROM revision WHERE rev_user = $1;",[ @user[ "user_id" ] ]).to_a
      erb :user
    end

    get "/random" do
      @pages = conn.exec("SELECT * FROM page;").to_a
      @random = @pages.sample

      redirect "/article/#{@random[ "page_id" ]}"
    end

    private

    def conn
      if ENV["RACK_ENV"] == 'production'
        @@conn ||= PG.connect(
          dbname: ENV["POSTGRES_DB"],
          host: ENV["POSTGRES_HOST"],
          password: ENV["POSTGRES_PASS"],
          user: ENV["POSTGRES_USER"]
        )
      else
        @@conn ||= PG.connect(dbname: "wiki_test")
      end
    end
  end
end
