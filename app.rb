require "sinatra"
require "slim"
require 'dotenv'
require_relative "models/deployment"

Dotenv.load

get "/" do
  @deployments = Deployment.all
  @current = @deployments.first

  slim :index
end
