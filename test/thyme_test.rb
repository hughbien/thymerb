require_relative '../lib/thyme'
require 'minitest/autorun'

class ThymeTest < Minitest::Test
  def setup
    @thyme = Thyme.new
    @thyme.set(:interval, 0)
    @thyme.set(:timer, 0)
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
  end

  def test_color_custom_warning
    @thyme.set(:warning, 5)
    assert_equal('default', @thyme.send(:color, 5*60-1))
    assert_equal('red,bold', @thyme.send(:color, 4))

    @thyme.set(:warning_color, 'yellow,bold')
    assert_equal('yellow,bold', @thyme.send(:color, 4))
  end

  def test_set
    assert_equal(0, @thyme.instance_variable_get('@timer')) # default timer is zero
    @thyme.set(:timer, 20*60)
    assert_equal(20*60, @thyme.instance_variable_get('@timer'))
  end

  def test_set_unknown_key
    assert_raises(ThymeError) { @thyme.set(:invalid, nil) }
  end

  def test_run
    @thyme.run
  end

  def test_before_hook
    @thyme.before { @before_flag = true }
    assert_nil(@thyme.instance_variable_get('@before_flag'))
    @thyme.run
    assert(@thyme.instance_variable_get('@before_flag'))
  end

  def test_after_hook
    @thyme.after { @after_flag = true }
    assert_nil(@thyme.instance_variable_get('@after_flag'))
    @thyme.run
    assert(@thyme.instance_variable_get('@after_flag'))
  end
end
