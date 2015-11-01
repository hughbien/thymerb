require_relative '../lib/thyme'
require 'minitest/autorun'
require 'optparse'

ENV['THYME_TEST'] = 'true'

class ConfigTest < Minitest::Test
  def setup
    @config = Thyme::Config.new
  end

  def test_set
    assert_equal('default', @config.break_color)
    @config.set(:break_color, 'red')
    assert_equal('red', @config.break_color)
  end

  def test_set_invalid
    assert_raises(Thyme::Error) do
      @config.set(:invalid_option, '')
    end
  end

  def test_use
    plugin = @config.use(ConfigTestPlugin)
    assert_equal(@config, plugin.thyme)
    @config.send_to_plugin(:increment)
    assert_equal(1, plugin.value)

    plugin2 = @config.use(ConfigTestPlugin, 10)
    @config.send_to_plugin(:increment, 15)
    assert_equal(25, plugin2.value)

    plugin3 = @config.use(ConfigTestPlugin) { 20 }
    @config.send_to_plugin(:increment)
    assert_equal(21, plugin3.value)
  end

  def test_hooks
    method = nil 
    @config.before(:all) { method = :before_all }
    @config.before { method = :before }
    @config.tick { method = :tick } 
    @config.after { method = :after }
    @config.after(:all) { method = :after_all }

    @config.send_to_plugin(:before_all)
    assert_equal(:before_all, method)
    @config.send_to_plugin(:before)
    assert_equal(:before, method)
    @config.send_to_plugin(:tick, 0)
    assert_equal(:tick, method)
    @config.send_to_plugin(:after, 0)
    assert_equal(:after, method)
    @config.send_to_plugin(:after_all)
    assert_equal(:after_all, method)
  end

  def test_option
    opt = OptionParser.new
    @config.option(opt, 't', 'thyme', 'new option') { }
    assert_match(/ -t/, opt.to_s)
    assert_match(/ --thyme/, opt.to_s)
    assert_match(/ new option/, opt.to_s)
  end
end

class ConfigTestPlugin
  attr_reader :thyme, :value

  def initialize(thyme, initial = 0, &block)
    @thyme = thyme
    @value = block ? block.call : initial
  end

  def increment(count = 1)
    @value += count
  end
end
