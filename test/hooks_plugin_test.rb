require_relative '../lib/thyme'
require 'minitest/autorun'

ENV['THYME_TEST'] = 'true'

class HooksPluginTest < Minitest::Test
  def setup
    @config = Thyme::Config.new
    @hooks = Thyme::HooksPlugin.new(@config)
    @called = []

    [:before_all, :before, :tick, :after, :after_all].each do |type|
      called = @called
      @hooks.add(type) { called.push(type) }
    end
  end

  def test_before_all
    @hooks.before_all
    assert_equal([:before_all], @called)
  end

  def test_before
    @hooks.before
    assert_equal([:before], @called)
  end

  def test_tick
    @hooks.tick(0)
    assert_equal([:tick], @called)
  end

  def test_after
    @hooks.after(0)
    assert_equal([:after], @called)
  end

  def test_after_all
    @hooks.after_all
    assert_equal([:after_all], @called)
  end
end
