class Deployment < Struct.new(:repo, :branch, :commit_hash, :timestamp, :author, :rollback)
  alias rollback? rollback

  def time
    DateTime.parse(timestamp).to_time
  end

  def commit_info
    @_cinfo ||= repo.commit_info commit_hash
  end

  def self.log_file
    File.expand_path ENV["REVISION_LOG"], File.dirname(__FILE__) + "/.."
  end

  def self.from_log(repo, log_line)
    log = DeploymentLog.parse(log_line)
    data = log.data.merge!(repo: repo, rollback: log.rollback?)
    self.new(*data.values_at(*self.members))
  end

  def self.all(repo)
    [].tap do |deployments|
      File.open(self.log_file, "r") do |f|
        f.each_line do |line|
          deployments.unshift Deployment.from_log(repo, line)
        end
      end
    end
  end

  class DeploymentLog < Struct.new(:log_line)
    def capture
      @_capture ||= log_line.match(self.pattern)
    end

    def match?
      !!self.capture
    end

    def data
      self.capture.names.map(&:to_sym).zip(self.capture.captures).to_h
    end

    def self.parse(log_line)
      [RegularDeployment.new(log_line), Rollback.new(log_line)].find(&:match?) or raise "Invalid log entry: #{log_line}"
    end
  end

  class RegularDeployment < DeploymentLog
    def pattern
      /^Branch (?<branch>.+?) \(at (?<commit_hash>\w+)\) deployed as release (?<timestamp>\d+) by (?<author>.+?);/
    end

    def rollback?; false; end
  end

  class Rollback < DeploymentLog
    def pattern
      /^(?<author>.+?); rolled back to release (?<timestamp>\d+)/
    end

    def rollback?; true; end
  end
end
