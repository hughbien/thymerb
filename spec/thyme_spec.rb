require 'rubygems'
require File.expand_path("#{File.dirname(__FILE__)}/../lib/thyme")
require 'minitest/spec'
require 'minitest/autorun'

describe Thyme do
  before do
    @thyme = Thyme.new
    @thyme.set(:interval, 0)
    @thyme.set(:timer, 0)
  end

  describe "#format" do
    it "formats minutes" do
      @thyme.send(:format, 25*60, 2).must_equal('25:00')
      @thyme.send(:format, 25*60-1, 2).must_equal('24:59')
      @thyme.send(:format, 5*60, 2).must_equal(' 5:00')
      @thyme.send(:format, 4*60+5, 2).must_equal(' 4:05')
    end
  end

  describe "#color" do
    it "uses default color for 5 minutes or over" do
      @thyme.send(:color, 5*60).must_equal('default')
    end

    it "uses bolded red for under 5 minutes" do
      @thyme.send(:color, 5*60-1).must_equal('red,bold')
    end

    it "uses warning to customize color threshold" do
      @thyme.set(:warning, 5)
      @thyme.send(:color, 5*60-1).must_equal('default')
      @thyme.send(:color, 4).must_equal('red,bold')
    end

    it "allows warning color to be customized" do
      @thyme.set(:warning_color, 'yellow,bold')
      @thyme.send(:color, 4).must_equal('yellow,bold')
    end
  end

  describe "#set" do
    it "defaults timer to zero" do
      @thyme.instance_variable_get('@timer').must_equal(0)
    end

    it "can set a new timer value" do
      @thyme.set(:timer, 20*60)
      @thyme.instance_variable_get('@timer').must_equal(20*60)
    end

    it "raises an error for unknown keys" do
      lambda { @thyme.set(:invalid, nil) }.must_raise(ThymeError)
    end
  end

  describe "#run" do
    it "runs the timer" do
      @thyme.run
    end
  end

  describe "hooks" do
    it "runs a before hook" do
      @thyme.before { @before_flag = true }
      @thyme.instance_variable_get('@before_flag').must_be_nil
      @thyme.run
      @thyme.instance_variable_get('@before_flag').must_equal(true)
    end

    it "runs a after hook" do
      @thyme.after { @after_flag = true }
      @thyme.instance_variable_get('@after_flag').must_be_nil
      @thyme.run
      @thyme.instance_variable_get('@after_flag').must_equal(true)
    end
  end
end
