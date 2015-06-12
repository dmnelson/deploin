require "sinatra"
require "slim"
require "dotenv"
require "json"
require_relative "models/repo"
require_relative "models/deployment"
require_relative "models/deploy"
require_relative "models/stream_decorator"

Dotenv.load

helpers do
  def commit_url(commit)
    "#{ENV['REPO_HOST_URL']}/#{ENV['REPO_OWNER']}/#{ENV['REPO_NAME']}/commit/#{commit.sha}"
  end

  def branch_url(branch)
    "#{ENV['REPO_HOST_URL']}/#{ENV['REPO_OWNER']}/#{ENV['REPO_NAME']}/tree/#{branch}"
  end
end

$semaphore = Mutex.new
$stream = StreamDecorator.new

get "/" do
  repo = Repo.load

  @branches = repo.branches.map(&:name)
  @deployments = Deployment.all(repo)
  @current = @deployments.first

  slim :index
end

post "/deploy" do
  raise "There is a deploy in progress already" if $semaphore.locked?
  branch = params[:branch] or raise "Branch must be specified"

  Thread.new do
    $semaphore.synchronize do
      $stream.start
      Deploy.new(branch: branch, log: $stream).execute
      $stream.finish
    end
  end
end

get "/deploy" do
  content_type "text/event-stream"

  stream do |out|
    $stream.subscribe(out)

    while $stream.in_progress? do
      sleep(0.5)
    end
  end
end
