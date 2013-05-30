class Thyme
  VERSION = '0.0.1'
  CONFIG_FILE = "#{ENV['HOME']}/.thymerc"

  def self.run
    sleep(25 * 60)
  rescue SignalException => e
    puts ""
  end
end
