require "bcat/ansi"

class StreamDecorator
  def initialize
    @history = []
    @subscriptions = []
    @logger = Logger.new(STDOUT)
    @in_progress = false
  end

  def start
    @in_progress = true
    @history.clear

    self.info "Started at: #{Time.now}"
    publish "event: start\n"
  end

  def method_missing(method, *args, &block)
    @logger.send(method, *args, &block)
    publish "data: #{Bcat::ANSI.new(args[0]).to_html}\n\n"
  end

  def finish
    publish "event: finish\n"
    self.info "Completed at: #{Time.now}"

    @in_progress = false
    @history.clear
  end

  def in_progress?
    @in_progress
  end

  def publish(message)
    @history << message

    @subscriptions.each do |sub|
      return @subscriptions -= [sub] if sub.closed?
      sub << message
    end
  end

  def subscribe(out)
    @history.each do |message|
      out << message
    end

    @subscriptions << out
  end
end
