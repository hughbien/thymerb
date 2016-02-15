module Thyme
  # Exposes application to the CLI in bin/thyme
  class Console
    attr_accessor :config

    def initialize
      @config = Config.new
    end

    def break!
      @config.break = true
    end

    def daemonize!
      @config.daemon = true
      Process.daemon if !ENV['THYME_TEST']
    end

    def description(d='')
      @config.description = d
    end

    def repeat!(count = 0)
      @config.repeat = count.to_i
    end

    def stop
      timer.stop
    end

    def run
      timer.run
    end

    # Loads the thymerc configuration file. Requires optparse b/c users can extend CLI via thymerc
    def load(optparse, &block)
      return if block.nil? && !File.exists?(Config::CONFIG_FILE)
      config = @config
      environment = Class.new do
        define_method(:set) { |opt,val| config.set(opt,val) }
        define_method(:use) { |plugin,*args,&b| config.use(plugin,*args,&b) }
        define_method(:before) { |*args,&block| config.before(*args,&block) }
        define_method(:after) { |*args,&block| config.after(*args,&block) }
        define_method(:tick) { |&block| config.tick(&block) }
        define_method(:option) { |sh,lo,desc,&b| config.option(optparse,sh,lo,desc,&b) }
      end.new

      if block # for test environment
        environment.instance_eval(&block)
      else
        environment.instance_eval(File.read(Config::CONFIG_FILE), Config::CONFIG_FILE)
      end
    end

    private

    def timer
      Timer.new(@config)
    end
  end
end
