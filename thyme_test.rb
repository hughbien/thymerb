require 'rubygems'
require "#{File.dirname(__FILE__)}/thyme"
require 'minitest'

Minitest.autorun

class ThymeTest < Minitest::Test
  def setup
    @thyme = Thyme.new
  end

  def test_format
    assert_equal('25:00', @thyme.send(:format, 25*60, 2))
    assert_equal('24:59', @thyme.send(:format, 25*60-1, 2))
    assert_equal(' 5:00', @thyme.send(:format, 5*60, 2))
    assert_equal(' 4:05', @thyme.send(:format, 4*60+5, 2))
  end

  def test_color
    assert_equal('default', @thyme.send(:color, 5*60))
    assert_equal('red,bold', @thyme.send(:color, 5*60-1))
  end

  def test_set
    assert_equal(25*60, @thyme.instance_variable_get('@timer'))
    @thyme.set(:timer, 20*60)
    assert_equal(20*60, @thyme.instance_variable_get('@timer'))
    assert_raises(ThymeError) { @thyme.set(:invalid, nil) }
  end
end
