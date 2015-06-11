require "open3"
require "logger"

class Exec
  def initialize(log: Logger.new(STDOUT), cwd: nil)
    @log = log
    @cwd = cwd
  end

  def command(command)
    @log.info "Executing: #{command} #{'at ' + @cwd.to_s if @cwd}"
    Open3.popen2e(command, chdir: @cwd.to_s) do |stdin, stdout, status|
      while line = stdout.gets
        @log.info line
      end
      status.value.success?
    end
  end
end
