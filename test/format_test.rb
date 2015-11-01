require_relative '../lib/thyme'
require 'minitest/autorun'
require 'minitest/mock'
require 'date'

ENV['THYME_TEST'] = 'true'

class FormatTest < Minitest::Test
  def setup
    @config = Thyme::Config.new
    @format = Thyme::Format.new(@config)
  end

  def test_seconds_since
    now = DateTime.now
    DateTime.stub(:now, now) do
      assert_equal(0, @format.seconds_since(now))
      assert_equal(10, @format.seconds_since(ago(now, 10)))
      assert_equal(60, @format.seconds_since(ago(now, 60)))
    end
  end

  def test_time_left
    @config.repeat = 0
    @config.repeat_index = 5
    assert_equal('0:40 (5)', @format.time_left(40, 0))

    @config.repeat = 6
    assert_equal('0:35 (5/6)', @format.time_left(35, 0))

    @config.repeat = 1
    assert_equal('0:30', @format.time_left(30, 0))

    @config.set(:interval, 1)
    assert_equal('0:01', @format.time_left(1, 0))
    assert_equal('0:01', @format.time_left(1, 1))
    assert_equal('  0:01', @format.time_left(1, 3))
    assert_equal(' 61:59', @format.time_left(61*60+59, 3))

    @config.set(:interval, 60)
    assert_equal(' 61m', @format.time_left(61*60+59, 3))
    assert_equal('15m', @format.time_left(15*60, 0))
  end

  def test_repeat_subtitle
    @config.repeat = 1
    assert_equal('', @format.repeat_subtitle)

    @config.repeat = 3
    @config.repeat_index = 2
    assert_equal('(2/3)', @format.repeat_subtitle)

    @config.repeat = 0
    assert_equal('(2)', @format.repeat_subtitle)
  end

  def test_tmux_color
    @config.set(:break_color, 'break')
    @config.set(:warning_color, 'warn')
    @config.set(:warning, 60)

    @config.break = true
    assert_equal('break', @format.tmux_color(0))
    assert_equal('break', @format.tmux_color(60))

    @config.break = false
    assert_equal('warn', @format.tmux_color(0))
    assert_equal('default', @format.tmux_color(60))
  end

  private
  
  def ago(now, seconds)
    Time.at(now.to_time.to_i - seconds).to_datetime
  end
end
