require "git"
require "logger"

class Repo
  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def commit_info(hash)
    @repo.gcommit(hash)
  end

  def method_missing(method, *args, &block)
    @repo.send(method, *args, &block)
  end

  def self.load(log: Logger.new(STDOUT))
    self.new Git.open(ENV["REPO_PATH"], log: log)
  rescue
    log.warn "No repo found - cloning from #{ENV['REPO_URL']}."
    self.new Git.clone(ENV["REPO_URL"], "", path: ENV["REPO_PATH"])
  end
end
