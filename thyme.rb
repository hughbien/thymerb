require 'ruby-progressbar'
require 'date'

class Thyme
  VERSION = '0.0.2'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"
  PID_FILE = "#{ENV['HOME']}/.thyme-pid"
  TMUX_FILE = "#{ENV['HOME']}/.thyme-tmux"
  OPTIONS = [:timer, :tmux]

  def initialize
    @timer = 25
    @tmux = false
  end

  def run
    @before.call if @before
    start = @timer * 60
    start_time = DateTime.now
    seconds = start + 1
    min_length = (seconds / 60).floor.to_s.length
    tmux_file = File.open(TMUX_FILE, "w")
    bar = ProgressBar.create(
      title: format(seconds-1, min_length),
      total: seconds,
      length: 50,
      format: '[%B] %t')
    while !bar.finished? && seconds > 0
      seconds = start - seconds_since(start_time)
      title = format(seconds, min_length)
      fg = color(seconds)
      bar.title = title
      bar.increment
      if @tmux
        tmux_file.truncate(0)
        tmux_file.rewind
        tmux_file.write("#[default]#[fg=#{fg}]#{title}#[default]")
        tmux_file.flush
      end
      sleep(1)
    end
  rescue SignalException => e
    puts ""
  ensure
    tmux_file.close
    @after.call if @after && seconds <= 0
    stop
  end

  def stop
    File.delete(TMUX_FILE) if File.exists?(TMUX_FILE)
    if File.exists?(PID_FILE)
      pid = File.read(PID_FILE).to_i
      File.delete(PID_FILE)
      Process.kill('TERM', pid) if pid > 1
    end
  end

  def daemonize!
    Process.daemon
    File.open(PID_FILE, "w") { |f| f.print(Process.pid) }
  end

  def set(opt, val)
    raise ThymeError.new("Invalid option: #{opt}") if !OPTIONS.include?(opt.to_sym)
    self.instance_variable_set("@#{opt}", val)
  end

  def before(&block)
    @before = block
  end

  def after(&block)
    @after = block
  end

  def option(optparse, short, long, desc, &block)
    optparse.on("-#{short}", "--#{long}", desc) { block.call; exit }
  end

  def load_config(optparse)
    return if !File.exists?(CONFIG_FILE)
    app = self
    Object.class_eval do
      define_method(:set) { |opt,val| app.set(opt,val) }
      define_method(:before) { |&block| app.before(&block) }
      define_method(:after) { |&block| app.after(&block) }
      define_method(:option) { |sh,lo,desc,&b| app.option(optparse,sh,lo,desc,&b) }
    end
    load(CONFIG_FILE, true)
  end

  private
  def seconds_since(time)
    ((DateTime.now - time) * 24 * 60 * 60).to_i
  end

  def format(seconds, min_length)
    min = (seconds / 60).floor
    lead = ' ' * (min_length - min.to_s.length)
    sec = (seconds % 60).floor
    sec = "0#{sec}" if sec.to_s.length == 1
    "#{lead}#{min}:#{sec}"
  end

  def color(seconds)
    seconds < (5*60) ? 'red,bold' : 'default'
  end
end

class ThymeError < StandardError; end;
