require "dotenv"
require "json"
require "sinatra"
require "slim"
require 'timeywimey'
require 'figlet'
require_relative "models/repo"
require_relative "models/deployment"
require_relative "models/deploy"
require_relative "models/stream_decorator"

Dotenv.load

helpers do
  def convert_spaces(str)
    str.gsub(' ',"\u00a0")
  end

  def hello
    Figlet::Typesetter.new(Figlet::Font.new("vendor/3D-ASCII.flf"))["Wobo Inc"]
  end

  def time_ago_in_words(from_time)
    Tw.time_ago_in_words from_time
  end

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

get "/refresh" do
  Repo.load.fetch
  redirect "/"
end

post "/deploy" do
  return (status 500 and body "DeployInProgress") if $semaphore.locked?
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

    until out.closed?
      $stream.publish("event: #{$stream.in_progress? ? "unavailable" : "available"}\ndata: \n\n")
      sleep(1.5)
    end
  end
end
