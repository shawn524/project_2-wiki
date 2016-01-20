module Wiki
  class Server < Sinatra::Base
    get "/" do
      erb :index
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
