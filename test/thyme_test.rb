require_relative '../lib/thyme'
require 'minitest/autorun'

ENV['THYME_TEST'] = 'true'

class ThymeTest < Minitest::Test
  def setup
    @thyme = Thyme.new
    @thyme.set(:interval, 0)
    @thyme.set(:timer, 0)
    @thyme.set(:timer_break, 0)
  end

  def test_format
    assert_equal('25:00', @thyme.send(:format, 25*60, 2))
    assert_equal('24:59', @thyme.send(:format, 25*60-1, 2))
    assert_equal(' 5:00', @thyme.send(:format, 5*60, 2))
    assert_equal(' 4:05', @thyme.send(:format, 4*60+5, 2))
  end

  def test_color
    assert_equal('default', @thyme.send(:color, 5*60))    # default for 5 minutes or over
    assert_equal('red,bold', @thyme.send(:color, 5*60-1)) # for under 5 minutes

    @thyme.break!
    assert_equal('default', @thyme.send(:color, 5*60-1))  # breaks always use default color
  end

  def test_color_custom_warning
    @thyme.set(:warning, 5)
    assert_equal('default', @thyme.send(:color, 5*60-1))
    assert_equal('red,bold', @thyme.send(:color, 4))

    @thyme.set(:warning_color, 'yellow,bold')
    assert_equal('yellow,bold', @thyme.send(:color, 4))
  end

  def test_set
    assert_equal(0, @thyme.instance_variable_get('@timer_break'))
    assert_equal(0, @thyme.instance_variable_get('@timer'))
    @thyme.set(:timer, 20*60)
    assert_equal(20*60, @thyme.instance_variable_get('@timer'))
  end

  def test_set_unknown_key
    assert_raises(ThymeError) { @thyme.set(:invalid, nil) }
  end

  def test_break
    refute(@thyme.instance_variable_get('@break'))
    @thyme.break!
    assert(@thyme.instance_variable_get('@break'))
  end

  def test_run
    refute(@thyme.instance_variable_get('@run'))
    @thyme.run
    assert(@thyme.instance_variable_get('@run'))
  end

  def test_before_hook
    @thyme.before { @before_flag = true }
    assert_nil(@thyme.instance_variable_get('@before_flag'))
    @thyme.run(true)
    assert(@thyme.instance_variable_get('@before_flag'))
  end

  def test_tick_hook
    count = 0
    @thyme.tick { count += 1 }
    @thyme.run(true)
    assert_equal(1, count) # tests only run one interval
  end

  def test_after_hook
    @thyme.after { @after_flag = true }
    assert_nil(@thyme.instance_variable_get('@after_flag'))
    @thyme.run(true)
    assert(@thyme.instance_variable_get('@after_flag'))
  end

  def test_plugin_should_initialize_passing_arguments
    block = proc { }
    mock_plugin = MiniTest::Mock.new
    mock_plugin.expect :new, nil do |*args, &blk|
      args == [@thyme, { a: 1, b: 2 }] && blk == block
    end
    @thyme.use mock_plugin, a: 1, b: 2, &block
    mock_plugin.verify
  end

  def test_plugin_should_call_methods
    mock_plugin   = MiniTest::Mock.new
    mock_instance = MiniTest::Mock.new
    mock_plugin.expect :new, mock_instance, [@thyme]
    mock_instance.expect :before, nil, []
    mock_instance.expect :tick,   nil, [0]
    mock_instance.expect :after,  nil, [0]
    @thyme.use mock_plugin
    @thyme.run(true)
    mock_plugin.verify
    mock_instance.verify
  end

  def test_plugin_should_call_methods_when_available
    mock_plugin   = MiniTest::Mock.new
    mock_instance = Object.new
    mock_plugin.expect :new, mock_instance, [@thyme]
    @thyme.use mock_plugin
    @thyme.run(true)
    mock_plugin.verify
  end
end

