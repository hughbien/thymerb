module Thyme
  class Console
    def initialize
      @config = Config.new
    end

    def break!
      @config.break = true
    end

    def daemonize!
      @config.daemon = true
      Process.daemon
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

    def load(optparse)
      return if !File.exists?(Config::CONFIG_FILE)
      config = @config
      environment = Class.new do
        define_method(:set) { |opt,val| config.set(opt,val) }
        define_method(:use) { |plugin,*args,&b| config.use(plugin,*args,&b) }
        define_method(:before) { |*args,&block| config.before(*args,&block) }
        define_method(:after) { |*args,&block| config.after(*args,&block) }
        define_method(:tick) { |&block| config.tick(&block) }
        define_method(:option) { |sh,lo,desc,&b| config.option(optparse,sh,lo,desc,&b) }
      end.new
      environment.instance_eval(File.read(Config::CONFIG_FILE), Config::CONFIG_FILE)
    end

    private

    def timer
      Timer.new(@config)
    end
  end
end
