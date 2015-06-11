require "open3"
require "logger"

class Exec
  def initialize(log: Logger.new(STDOUT), cwd: nil)
    @log = log
    @cwd = cwd
  end

  def command(command)
    if(@cwd)
      command = "cd #{@cwd} && #{command}"
    end

    @log.info "Executing: #{command}"
    Open3.popen2e(command) do |stdin, stdout, status|
      while line = stdout.gets
        @log.info line
      end
      status.value.success?
    end
  end
end
