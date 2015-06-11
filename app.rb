require "sinatra"
require "slim"
require_relative "models/deployment"

get "/" do
  @deployments = Deployment.all
  @current = @deployments.first

  slim :index
end
