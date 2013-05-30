require 'ruby-progressbar'

class Thyme
  VERSION = '0.0.1'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"

  def self.run
    start = 25 * 60
    seconds = start + 1
    min_length = (seconds / 60).to_s.length
    outfile = File.open("#{ENV['HOME']}/.thyme-tmux", "w")
    bar = ProgressBar.create(
      title: format(seconds-1, min_length),
      total: seconds,
      length: 50,
      format: '[%B] %t')
    while !bar.finished? && seconds > 0
      seconds -= 1
      title = self.format(seconds, min_length)
      color = self.color(seconds, start)
      bar.title = title
      bar.increment
      outfile.truncate(0)
      outfile.rewind
      outfile.write("#[default]#[fg=#{color}]#{title}#[default]")
      outfile.flush
      sleep(1)
    end
  rescue SignalException => e
    puts ""
  ensure
    outfile.close
  end

  private
  def self.format(seconds, min_length)
    min = seconds / 60
    lead = ' ' * (min_length - min.to_s.length)
    sec = seconds % 60
    sec = "0#{sec}" if sec.to_s.length == 1
    "#{lead}#{min}:#{sec}"
  end

  def self.color(seconds, start)
    seconds < (5*60) ? 'red,bold' : 'default'
  end
end
