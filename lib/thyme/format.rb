module Thyme
  # Methods used to nicely format output to the user
  class Format
    def initialize(config)
      @config = config
    end

    def seconds_since(time)
      ((DateTime.now - time) * 24 * 60 * 60).to_i
    end

    # Displays time depending on configured interval eg. 15m OR 15:20
    def time_left(seconds, min_length)
      min = (seconds / 60).floor
      lead = ' ' * [0, min_length - min.to_s.length].max
      sec = (seconds % 60).floor
      sec = "0#{sec}" if sec.to_s.length == 1
      @config.interval < 60 ?
        "#{lead}#{min}:#{sec} #{repeat_subtitle}".sub(/\s*$/, '') :
        "#{lead}#{min}m #{repeat_subtitle}".sub(/\s*$/, '')
    end

    def repeat_subtitle
      if @config.repeat == 1
        ''
      elsif @config.repeat == 0
        "(#{@config.repeat_index})"
      else
        "(#{@config.repeat_index}/#{@config.repeat})"
      end
    end

    def tmux_color(seconds)
      if @config.break
        @config.break_color
      elsif seconds < @config.warning
        @config.warning_color
      else
        @config.default_color
      end
    end
  end
end
