require 'ruby-progressbar'

class Thyme
  VERSION = '0.0.1'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"
  PID_FILE = "#{ENV['HOME']}/.thyme-pid"
  TMUX_FILE = "#{ENV['HOME']}/.thyme-tmux"
  OPTIONS = [:timer]

  def initialize
    @timer = 25
  end

  def run
    start = @timer * 60
    seconds = start + 1
    min_length = (seconds / 60).to_s.length
    tmux_file = File.open(TMUX_FILE, "w")
    bar = ProgressBar.create(
      title: format(seconds-1, min_length),
      total: seconds,
      length: 50,
      format: '[%B] %t')
    while !bar.finished? && seconds > 0
      seconds -= 1
      title = format(seconds, min_length)
      fg = color(seconds)
      bar.title = title
      bar.increment
      tmux_file.truncate(0)
      tmux_file.rewind
      tmux_file.write("#[default]#[fg=#{fg}]#{title}#[default]")
      tmux_file.flush
      sleep(1)
    end
  rescue SignalException => e
    puts ""
  ensure
    tmux_file.close
  end

  def stop
    File.delete(TMUX_FILE)
    if File.exists?(PID_FILE)
      pid = File.read(PID_FILE).to_i
      Process.kill('TERM', pid) if pid > 1
      File.delete(PID_FILE)
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

  def load_config
    return if !File.exists?(CONFIG_FILE)
    app = self
    Object.class_eval do
      define_method(:set) { |opt, val| app.set(opt, val) }
    end
    load(CONFIG_FILE, true)
  end

  private
  def format(seconds, min_length)
    min = seconds / 60
    lead = ' ' * (min_length - min.to_s.length)
    sec = seconds % 60
    sec = "0#{sec}" if sec.to_s.length == 1
    "#{lead}#{min}:#{sec}"
  end

  def color(seconds)
    seconds < (5*60) ? 'red,bold' : 'default'
  end
end

class ThymeError < StandardError; end;
