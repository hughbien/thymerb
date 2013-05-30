require 'rubygems'
require "#{File.dirname(__FILE__)}/thyme"
require 'minitest/autorun'

class ThymeTest < MiniTest::Unit::TestCase
  def setup
  end

  def test_truth
    assert(true)
  end
end
