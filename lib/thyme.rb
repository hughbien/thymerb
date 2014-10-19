require 'ruby-progressbar'
require 'date'

class Thyme
  VERSION = '0.0.14'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"
  PID_FILE = "#{ENV['HOME']}/.thyme-pid"
  TMUX_FILE = "#{ENV['HOME']}/.thyme-tmux"
  OPTIONS = [:interval, :timer, :timer_break, :tmux, :tmux_theme, :warning, :warning_color]

  def initialize
    @break = false
    @interval = 1
    @timer = 25 * 60
    @timer_break = 5 * 60
    @tmux = false
    @tmux_theme = "#[default]#[fg=%s]%s#[default]" 
    @warning = 5 * 60
    @warning_color = "red,bold"
    @plugins = []
  end

  def use(plugin_class, *args, &block)
    @plugins << plugin_class.new(self, *args, &block)
  end

  def run(force=false)
    if force
      running? ? stop_timer : start_timer
    else
      @run = true
    end
  end

  def break!
    @break = true
  end

  def daemonize!
    @daemon = true
    Process.daemon
  end

  def daemon?
    !!@daemon
  end

  def set(opt, val)
    raise ThymeError.new("Invalid option: #{opt}") if !OPTIONS.include?(opt.to_sym)
    self.instance_variable_set("@#{opt}", val)
  end

  def before(&block)
    hooks_plugin.add(:before, &block)
  end

  def after(&block)
    hooks_plugin.add(:after, &block)
  end

  def tick(&block)
    hooks_plugin.add(:tick, &block)
  end

  def option(optparse, short, long, desc, &block)
    optparse.on("-#{short}", "--#{long}", desc) do |*args|
      self.instance_exec(*args, &block)
      exit if !@run
    end
  end

  def load_config(optparse)
    return if !File.exists?(CONFIG_FILE)
    app = self
    environment = Class.new do
      define_method(:set) { |opt,val| app.set(opt,val) }
      define_method(:use) { |plugin,*args,&b| app.use(plugin,*args,&b) }
      define_method(:before) { |&block| app.before(&block) }
      define_method(:after) { |&block| app.after(&block) }
      define_method(:tick) { |&block| app.tick(&block) }
      define_method(:option) { |sh,lo,desc,&b| app.option(optparse,sh,lo,desc,&b) }
    end.new
    environment.instance_eval(File.read(CONFIG_FILE), CONFIG_FILE)
  end

  def running?
    File.exists?(PID_FILE)
  end

  private

  def start_timer
    File.open(PID_FILE, "w") { |f| f.print(Process.pid) }
    seconds_start = @break ? @timer_break : @timer
    seconds_left = seconds_start + 1
    start_time = DateTime.now
    min_length = (seconds_left / 60).floor.to_s.length
    tmux_file = File.open(TMUX_FILE, "w") if @tmux
    started = false
    bar = ENV['THYME_TEST'].nil? && !daemon? ?
      ProgressBar.create(
        title: format(seconds_left-1, min_length),
        total: seconds_start,
        length: 50,
        format: '[%B] %t') : nil
    while seconds_left > 0
      seconds_passed = seconds_since(start_time)
      seconds_left = [seconds_start - seconds_passed, 0].max
      title = format(seconds_left, min_length)
      fg = color(seconds_left)
      if bar
        bar.title = title
        bar.progress = seconds_passed
      end
      if @tmux
        tmux_file.truncate(0)
        tmux_file.rewind
        tmux_file.write(@tmux_theme % [fg, title])
        tmux_file.flush
      end
      unless started
        started = true
        send_to_plugin :before
      end
      send_to_plugin :tick, seconds_left
      sleep(@interval)
    end
  rescue SignalException => e
    puts ""
  ensure
    tmux_file.close if tmux_file
    File.delete(TMUX_FILE) if File.exists?(TMUX_FILE)
    File.delete(PID_FILE) if File.exists?(PID_FILE)
    seconds_left = [seconds_start - seconds_since(start_time), 0].max
    send_to_plugin :after, seconds_left
  end

  def stop_timer
    pid = File.read(PID_FILE).to_i
    Process.kill('TERM', pid) if pid > 1
  rescue Errno::ESRCH # process is already dead, cleanup files and restart
    File.delete(TMUX_FILE) if File.exists?(TMUX_FILE)
    File.delete(PID_FILE) if File.exists?(PID_FILE)
  end

  def send_to_plugin(message, *args)
    @plugins.each do |plugin|
      begin
        plugin.public_send(message, *args) if plugin.respond_to?(message)
      rescue
        $stderr.puts "Exception raised from #{plugin.class}:", $!, $@
      end
    end
  end

  def hooks_plugin
    @hooks_plugin ||= begin
      use ThymeHooksPlugin
      @plugins.last
    end
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
    !@break && seconds < @warning ? @warning_color : 'default'
  end
end

class ThymeError < StandardError; end;

class ThymeHooksPlugin
  def initialize(app)
    @app = app
    @hooks = {before: [], tick: [], after: []}
  end

  def add(type, &block)
    @hooks[type] << block
  end

  def before
    @hooks[:before].each { |b| @app.instance_exec(&b) }
  end

  def tick(seconds_left)
    @hooks[:tick].each { |t| @app.instance_exec(seconds_left, &t) }
  end

  def after(seconds_left)
    @hooks[:after].each { |a| @app.instance_exec(seconds_left, &a) }
  end
end
