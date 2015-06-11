require "sinatra"
require "slim"
require 'dotenv'
require_relative "models/repo"
require_relative "models/deployment"

Dotenv.load

helpers do
  def commit_url(commit)
    "#{ENV['REPO_HOST_URL']}/#{ENV['REPO_OWNER']}/#{ENV['REPO_NAME']}/commit/#{commit.sha}"
  end
end

get "/" do
  @deployments = Deployment.all
  @current = @deployments.first
  @repo =

  slim :index
end
