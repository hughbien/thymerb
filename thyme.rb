require 'ruby-progressbar'

class Thyme
  VERSION = '0.0.1'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"

  def self.run
    seconds = 25 * 60 + 1
    min_length = (seconds / 60).to_s.length
    bar = ProgressBar.create(
      title: format(seconds-1, min_length),
      total: seconds,
      length: 50,
      format: '[%B] %t')
    while !bar.finished? && seconds > 0
      seconds -= 1
      bar.title = self.format(seconds, min_length)
      bar.increment
      sleep(1)
    end
  rescue SignalException => e
    puts ""
  end

  private
  def self.format(seconds, min_length)
    min = seconds / 60
    lead = ' ' * (min_length - min.to_s.length)
    sec = seconds % 60
    sec = "0#{sec}" if sec.to_s.length == 1
    "#{lead}#{min}:#{sec}"
  end
end
