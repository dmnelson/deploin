require "sinatra"
require "slim"
require "dotenv"
require "json"
require_relative "models/repo"
require_relative "models/deployment"

Dotenv.load

helpers do
  def commit_url(commit)
    "#{ENV['REPO_HOST_URL']}/#{ENV['REPO_OWNER']}/#{ENV['REPO_NAME']}/commit/#{commit.sha}"
  end

  def branch_url(branch)
    "#{ENV['REPO_HOST_URL']}/#{ENV['REPO_OWNER']}/#{ENV['REPO_NAME']}/tree/#{branch}"
  end
end

get "/" do
  repo = Repo.load

  @branches = repo.branches.map(&:name)
  @deployments = Deployment.all(repo)
  @current = @deployments.first

  slim :index
end

get "/deploy/*" do
  content_type "text/event-stream"

  branch = params[:splat].first
  stream do |out|

    out << "event: start\n"
    out << "data: " + { branch: branch, time: Time.now }.to_json + "\n\n"

    10.times do |i|
      out << "data: #{i} bottle(s) on a wall...\n\n"
      sleep 0.5
    end

    out << "event: finish\n"
    out << "data: #{Time.now}\n\n"
  end
end
