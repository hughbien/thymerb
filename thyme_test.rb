require 'rubygems'
require "#{File.dirname(__FILE__)}/thyme"
require 'minitest'

Minitest.autorun

class ThymeTest < Minitest::Test
  def setup
  end

  def test_setup
    assert_equal('25:00', Thyme.send(:format, 25*60, 2))
    assert_equal('24:59', Thyme.send(:format, 25*60-1, 2))
    assert_equal(' 5:00', Thyme.send(:format, 5*60, 2))
    assert_equal(' 4:05', Thyme.send(:format, 4*60+5, 2))
  end
end
