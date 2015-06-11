class Deployment < Struct.new(:branch, :commit_hash, :timestamp, :author)

  REGEX = /^Branch (?<branch>.+?) \(at (?<commit_hash>\w+)\) deployed as release (?<timestamp>\d+) by (?<author>.+?);/

  def time
    Time.parse(timestamp)
  end

  def self.log_file
    ENV["REVISION_LOG"]
  end

  def self.from_log(log_line)
    if match = log_line.match(REGEX)
      data = match.names.map(&:to_sym).zip(match.captures).to_h
      self.new(*data.values_at(*self.members))
    else
      raise "Invalid log entry: #{log_line}"
    end
  end

  def self.all
    [].tap do |deployments|
      File.open(self.log_file, "r") do |f|
        f.each_line do |line|
          deployments.unshift Deployment.from_log(line)
        end
      end
    end
  end
end
