require 'ruby-progressbar'
require 'date'

class Thyme
  VERSION = '0.0.4'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"
  PID_FILE = "#{ENV['HOME']}/.thyme-pid"
  TMUX_FILE = "#{ENV['HOME']}/.thyme-tmux"
  OPTIONS = [:timer, :tmux, :interval]

  def initialize
    @timer = 25
    @tmux = false
    @interval = 1
  end

  def run
    @before.call if @before
    seconds_start = @timer * 60
    seconds_left = seconds_start + 1
    start_time = DateTime.now
    min_length = (seconds_left / 60).floor.to_s.length
    tmux_file = File.open(TMUX_FILE, "w")
    bar = ProgressBar.create(
      title: format(seconds_left-1, min_length),
      total: seconds_start,
      length: 50,
      format: '[%B] %t')
    while seconds_left > 0
      seconds_passed = seconds_since(start_time)
      seconds_left = seconds_start - seconds_passed
      title = format(seconds_left, min_length)
      fg = color(seconds_left)
      bar.title = title
      bar.progress = seconds_passed
      if @tmux
        tmux_file.truncate(0)
        tmux_file.rewind
        tmux_file.write("#[default]#[fg=#{fg}]#{title}#[default]")
        tmux_file.flush
      end
      sleep(@interval)
    end
  rescue SignalException => e
    puts ""
  ensure
    tmux_file.close
    @after.call if @after && seconds_left <= 0
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
    seconds = [0, seconds].max
    min = (seconds / 60).floor
    lead = ' ' * (min_length - min.to_s.length)
    sec = (seconds % 60).floor
    sec = "0#{sec}" if sec.to_s.length == 1
    @interval < 60 ?
      "#{lead}#{min}:#{sec}" :
      "#{lead}#{min}m"
  end

  def color(seconds)
    seconds < (5*60) ? 'red,bold' : 'default'
  end
end

class ThymeError < StandardError; end;
