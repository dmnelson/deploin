require "bcat/ansi"

class StreamDecorator
  def initialize(out)
    @out = out
    @logger = Logger.new(STDOUT)
  end

  def start
    self.info "Started at: #{Time.now}"
    @out << "event: start\n"
  end

  def method_missing(method, *args, &block)
    @logger.send(method, *args, &block)
    @out << "data: #{Bcat::ANSI.new(args[0]).to_html}\n\n"
  end

  def finish
    @out << "event: finish\n"
    self.info "Completed at: #{Time.now}"
  end
end
