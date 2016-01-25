require "pg"
require "pry"
require "sinatra/base"
require "bcrypt"
require "bundler/setup"
require "redcarpet"
require "sanitize"

require_relative "server"


run Wiki::Server
