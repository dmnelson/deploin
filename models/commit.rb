class Commit
  attr_reader :sha, :commit_info

  def initialize(sha, gcommit)
    @sha = sha
    @commit_info = init(gcommit)
  end

  def message
    commit_info.message
  end

  def author
    commit_info.author.name
  end

  def init(gcommit)
    gcommit.tap { |c| c.name } rescue UnrecognizedCommit.new(sha)
  end
end

class UnrecognizedCommit < Struct.new(:sha)
  def message; sha; end
  def author; OpenStruct.new(name: "Unknown"); end
end
