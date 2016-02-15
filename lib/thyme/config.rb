module Thyme
  # Configure state for the application. This can be done via the thymerc file or CLI flags.
  # Public methods in this file are exposed to the thymerc file.
  class Config
    CONFIG_FILE = "#{ENV['HOME']}/.thymerc"
    PID_FILE = "#{ENV['HOME']}/.thyme-pid"
    TMUX_FILE = "#{ENV['HOME']}/.thyme-tmux"
    OPTIONS = [:break_color, :interval, :timer, :timer_break, :tmux, :tmux_theme, :warning, :warning_color]
    OPTIONS.each { |opt| attr_reader(opt) }
    attr_accessor :break, :daemon, :repeat, :repeat_index, :description

    def initialize
      # options set via config file
      @break_color = 'default'
      @interval = 1
      @timer = 25 * 60
      @timer_break = 5 * 60
      @tmux = false
      @tmux_theme = "#[default]#[fg=%s]%s#[default]" 
      @warning = 5 * 60
      @warning_color = 'red,bold'

      # plugins set via config file
      @plugins = []
      @hooks_plugin = use(Thyme::HooksPlugin)

      # settings via command line
      @break = false
      @daemon = false
      @repeat = 1
      @repeat_index = 1
      @description = nil
    end

    def set(opt, val)
      raise Thyme::Error.new("Invalid option: #{opt}") if !OPTIONS.include?(opt.to_sym)
      self.instance_variable_set("@#{opt}", val)
    end

    def use(plugin_class, *args, &block)
      plugin = plugin_class.new(self, *args, &block)
      @plugins << plugin
      plugin
    end

    def before(kind = :each, &block)
      type = kind == :all ? :before_all : :before
      @hooks_plugin.add(type, &block)
    end

    def after(kind = :each, &block)
      type = kind == :all ? :after_all : :after
      @hooks_plugin.add(type, &block)
    end

    def tick(&block)
      @hooks_plugin.add(:tick, &block)
    end

    def option(optparse, short, long, desc, &block)
      optparse.on("-#{short}", "--#{long}", desc) do |*args|
        self.instance_exec(*args, &block)
        exit if !@run
      end
    end

    def send_to_plugin(message, *args)
      @plugins.each do |plugin|
        begin
          plugin.public_send(message, *args) if plugin.respond_to?(message)
        rescue
          $stderr.puts "Exception raised from #{plugin.class}:", $!, $@
        end
      end
    end
  end
end
