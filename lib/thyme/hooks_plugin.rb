module Thyme
  class HooksPlugin
    def initialize(config)
      @config = config
      @hooks = {before_all: [], before: [], tick: [], after: [], after_all: []}
    end

    def add(type, &block)
      @hooks[type] << block
    end

    def before_all
      @hooks[:before_all].each { |b| @config.instance_exec(&b) }
    end

    def before
      @hooks[:before].each { |b| @config.instance_exec(&b) }
    end

    def tick(seconds_left)
      @hooks[:tick].each { |t| @config.instance_exec(seconds_left, &t) }
    end

    def after(seconds_left)
      @hooks[:after].each { |a| @config.instance_exec(seconds_left, &a) }
    end

    def after_all
      @hooks[:after_all].each { |a| @config.instance_exec(&a) }
    end
  end
end
