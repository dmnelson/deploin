require "logger"
require_relative "repo"
require_relative "exec"

class Deploy

  def initialize(environment: "staging", branch: "master", user: nil, log: Logger.new(STDOUT))
    @environment = environment
    @branch = branch
    @user = user
    @repo = Repo.load()
    @exec = Exec.new(cwd: @repo.dir, log: log)
  end

  def execute
    pull_and_checkout
    bundle_install
    cap_deploy
  end

  private

  attr_reader :branch, :user, :repo, :environment

  def pull_and_checkout
    repo.pull("origin", branch)
    repo.checkout(branch)
  end

  def bundle_install
    bundle("install --deployment")
  end

  def cap_deploy
    exec("cp example.env .env")
    bundle("exec cap #{environment} deploy BRANCH=#{branch}")
  end

  def bundle(c)
    exec("BUNDLE_GEMFILE=#{repo.dir}/Gemfile bundle #{c}")
  end

  def exec(c)
    @exec.command(c) or raise "Deploy failed!"
  end
end