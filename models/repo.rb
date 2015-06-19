require "git"
require "logger"

class Repo
  attr_reader :repo

  def initialize(repo, log: log)
    @repo = Git.open(repo, log: log)
  end

  def commit_info(hash)
    gcommit(hash)
  end

  def method_missing(method, *args, &block)
    Repo.mutex.synchronize do
      @repo.send(method, *args, &block)
    end
  end

  def self.mutex
    @mutex ||= Mutex.new
  end

  def self.load(log: Logger.new(STDOUT))
    mutex.synchronize do
      begin
        self.new ENV["REPO_PATH"], log: log
      rescue
        log.warn "No repo found - cloning from #{ENV['REPO_URL']}."
        Git.clone(ENV["REPO_URL"], "", path: ENV["REPO_PATH"])
        retry
      end
    end
  end
end
