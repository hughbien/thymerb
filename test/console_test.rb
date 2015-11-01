require_relative '../lib/thyme'
require 'minitest/autorun'
require 'optparse'

ENV['THYME_TEST'] = 'true'

class ConsoleTest < Minitest::Test
  def setup
    @console = Thyme::Console.new
    @config = @console.config
  end

  def test_break
    refute(@config.break)
    @console.break!
    assert(@config.break)
  end

  def test_daemonize
    refute(@config.daemon)
    @console.daemonize!
    assert(@config.daemon)
  end

  def test_repeat
    assert_equal(1, @config.repeat)
    @console.repeat!(10)
    assert_equal(10, @config.repeat)
  end

  def test_load
    opt = OptionParser.new
    hooks = {}
    plugin = nil

    @console.load(opt) do
      set :timer, 1337
      plugin = use(ConsoleTestPlugin)
      before(:all) { hooks[:before_all] = true }
      before { hooks[:before] = true }
      tick { hooks[:tick] = true }
      after { hooks[:after] = true }
      after(:all) { hooks[:after_all] = true }
      option(:t, :thyme, 'new command') { hooks[:cmd] = true }
    end

    assert(hooks.empty?)
    assert(plugin.hooks.empty?)

    @config.send_to_plugin(:before_all)
    @config.send_to_plugin(:before)
    @config.send_to_plugin(:tick, 0)
    @config.send_to_plugin(:after, 0)
    @config.send_to_plugin(:after_all)

    [:before_all, :before, :tick, :after, :after_all].each do |name|
      assert(hooks[name])
      assert(plugin.hooks[name])
    end
  end
end

class ConsoleTestPlugin
  attr_reader :hooks

  def initialize(thyme)
    @hooks = {}
  end

  def respond_to?(*args)
    true
  end

  def method_missing(name, *args, &block)
    @hooks[name] ||= 0
    @hooks[name] += 1
  end
end
