module Thyme::Plugins

  class BaseHookPlugin
    def initialize(app, &block)
      @app = app
      @block = block
      raise "No block given!" unless block
    end
    def invoke_block(*args)
      @app.instance_exec(*args, &@block)
    end
  end

  class BeforeHook < BaseHookPlugin
    def before
      invoke_block
    end
  end

  class AfterHook < BaseHookPlugin
    def after(seconds_left)
      invoke_block seconds_left
    end
  end

  class TickHook < BaseHookPlugin
    def tick(seconds_left)
      invoke_block seconds_left
    end
  end

end
