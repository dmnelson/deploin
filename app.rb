require "sinatra"
require "slim"
require "dotenv"
require "json"
require_relative "models/repo"
require_relative "models/deployment"
require_relative "models/deploy"

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

class StreamDecorator
  def initialize(out)
    @out = out
  end

  def write(args)
    @out << args
  end

  def close
    @out.close
  end

  def method_missing(method, *args, &block)
    @out.send(method, *args, &block)
  end
end

get "/deploy/*" do
  content_type "text/event-stream"
  branch = params[:splat].first or raise "Branch must be specified"
  stream do |out|
    out << "Started at: #{Time.now}\n\n"
    Deploy.new(branch: branch, log: Logger.new(StreamDecorator.new(out))).execute()
    out << "Completed at: #{Time.now}\n\n"
  end
end
