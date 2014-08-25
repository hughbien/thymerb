require 'ruby-progressbar'
require 'date'

class Thyme
  VERSION = '0.0.11'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"
  PID_FILE = "#{ENV['HOME']}/.thyme-pid"
  TMUX_FILE = "#{ENV['HOME']}/.thyme-tmux"
  OPTIONS = [:break, :interval, :timer, :tmux, :tmux_theme, :warning, :warning_color]

  attr_reader :daemon

  def initialize
    @break = 5 * 60
    @interval = 1
    @mode = :main
    @timer = 25 * 60
    @tmux = false
    @tmux_theme = "#[default]#[fg=%s]%s#[default]" 
    @warning = 5 * 60
    @warning_color = "red,bold"
  end

  def run
    running? ? stop_timer : start_timer
  end

  def break!
    @mode = :break
  end

  def daemonize!
    @daemon = true
    Process.daemon
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
    optparse.on("-#{short}", "--#{long}", desc) { self.instance_exec(&block); exit }
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

  def running?
    File.exists?(PID_FILE)
  end

  private

  def start_timer
    File.open(PID_FILE, "w") { |f| f.print(Process.pid) }
    before_hook = @before
    seconds_start = @mode == :main ? @timer : @break
    seconds_left = seconds_start + 1
    start_time = DateTime.now
    min_length = (seconds_left / 60).floor.to_s.length
    tmux_file = File.open(TMUX_FILE, "w") if @tmux
    bar = ProgressBar.create(
      title: format(seconds_left-1, min_length),
      total: seconds_start,
      length: 50,
      format: '[%B] %t') if !@daemon
    while seconds_left > 0
      seconds_passed = seconds_since(start_time)
      seconds_left = [seconds_start - seconds_passed, 0].max
      title = format(seconds_left, min_length)
      fg = color(seconds_left)
      if !@daemon
        bar.title = title
        bar.progress = seconds_passed
      end
      if @tmux
        tmux_file.truncate(0)
        tmux_file.rewind
        tmux_file.write(@tmux_theme % [fg, title])
        tmux_file.flush
      end
      if before_hook
        self.instance_exec(&before_hook)
        before_hook = nil
      end
      sleep(@interval)
    end
  rescue SignalException => e
    puts ""
  ensure
    tmux_file.close if tmux_file
    File.delete(TMUX_FILE) if File.exists?(TMUX_FILE)
    File.delete(PID_FILE) if File.exists?(PID_FILE)
    seconds_left = [seconds_start - seconds_since(start_time), 0].max
    self.instance_exec(seconds_left, &@after) if @after
  end

  def stop_timer
    pid = File.read(PID_FILE).to_i
    Process.kill('TERM', pid) if pid > 1
  rescue Errno::ESRCH # process is already dead, cleanup files and restart
    File.delete(TMUX_FILE) if File.exists?(TMUX_FILE)
    File.delete(PID_FILE) if File.exists?(PID_FILE)
  end

  def seconds_since(time)
    ((DateTime.now - time) * 24 * 60 * 60).to_i
  end

  def format(seconds, min_length)
    min = (seconds / 60).floor
    lead = ' ' * (min_length - min.to_s.length)
    sec = (seconds % 60).floor
    sec = "0#{sec}" if sec.to_s.length == 1
    @interval < 60 ?
      "#{lead}#{min}:#{sec}" :
      "#{lead}#{min}m"
  end

  def color(seconds)
    @mode == :main && seconds < @warning ? @warning_color : 'default'
  end
end

class ThymeError < StandardError; end;
