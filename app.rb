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
    @logger = Logger.new(STDOUT)
  end

  def start
    self.info "Started at: #{Time.now}"
    @out << "event: start\n"
  end

  def method_missing(method, *args, &block)
    @logger.send(method, *args, &block)
    @out << "data: #{args[0 ]}\n\n"
  end

  def finish
    @out << "event: finish\n"
    self.info "Completed at: #{Time.now}"
  end
end

get "/deploy/*" do
  content_type "text/event-stream"
  branch = params[:splat].first or raise "Branch must be specified"
  stream do |out|
    stream = StreamDecorator.new(out)
    stream.start
    Deploy.new(branch: branch, log: stream).execute()
    stream.info("Colorido: [0m[30mDEBUG[0m [[32m56c36123[0m] [32m	deb799edd0ad582814efa7f1508c5f2c57aab971	refs/pull/991/head")
    stream.finish
  end
end
