module Thyme
  # The actual timer logic where you can pause, unpause, or stop one or more timers
  class Timer
    def initialize(config)
      @config = config
      @format = Format.new(config)
      @tmux = Tmux.new(config)
    end

    def stop
      send_signal('TERM')
    end

    def run
      # pause/unpause timer if it's already running
      send_signal('USR1') and return if File.exists?(Config::PID_FILE)

      begin
        File.open(Config::PID_FILE, "w") { |f| f.print(Process.pid) }
        @tmux.open
        if @config.repeat == 1
          run_single
        else
          while @config.repeat_index <= @config.repeat || @config.repeat == 0
            @config.break = false
            run_single
            if @config.repeat_index < @config.repeat || @config.repeat == 0
              @config.break = true
              run_single
            end
            @config.repeat_index += 1
          end
        end
      rescue Thyme::StopTimer
        # stop signal received
      ensure
        @tmux.close
        File.delete(Config::PID_FILE) if File.exists?(Config::PID_FILE)
      end
    end

    private

    # TODO: refactor this method, too large!
    def run_single
      seconds_total = @config.break ? @config.timer_break : @config.timer
      seconds_left = seconds_total + 1
      start_time = DateTime.now
      paused_time = nil
      min_length = (seconds_left / 60).floor.to_s.length
      started = false
      @bar ||= ENV['THYME_TEST'].nil? && !@config.daemon ?
        ProgressBar.create(
          title: @format.time_left(seconds_left-1, min_length),
          total: seconds_total,
          length: 50,
          format: '[%B] %t') : nil
      @bar.reset if @bar
      while seconds_left > 0
        begin
          if paused_time
            sleep(@config.interval)
            next
          end
          seconds_passed = @format.seconds_since(start_time)
          seconds_left = [seconds_total - seconds_passed, 0].max
          title = @format.time_left(seconds_left, min_length)
          if @bar
            @bar.title = title
            if seconds_left == 0 && !last?
              @bar.progress = seconds_passed - 0.01 # prevent bar from finishing
            else
              @bar.progress = seconds_passed
            end
          end
          @tmux.tick(@format.tmux_color(seconds_left), title)
          unless started
            started = true
            @config.send_to_plugin(:before_all) if first?
            @config.send_to_plugin(:before)
          end
          @config.send_to_plugin(:tick, seconds_left)
          sleep(@config.interval)
        rescue SignalException => e
          if e.signm == 'SIGUSR1' && paused_time.nil?
            paused_time = DateTime.now
          elsif e.signm == 'SIGUSR1'
            delta = DateTime.now - paused_time
            start_time += delta
            paused_time = nil
          else
            puts ""
            @interrupted = true
            raise Thyme::StopTimer
          end
        end
      end
    ensure
      seconds_left = [seconds_total - @format.seconds_since(start_time), 0].max
      @config.send_to_plugin(:after, seconds_left)
      @config.send_to_plugin(:after_all) if @interrupted || last?
    end

    def first?
      @config.repeat == 1 || (!@config.break && @config.repeat_index == 1)
    end

    def last?
      @config.repeat == @config.repeat_index
    end

    # Since timers can be daemonized, we'll use Unix signals to trigger events such as
    # pause/unpause in a separate process.
    def send_signal(signal)
      pid = File.read(Config::PID_FILE).to_i
      Process.kill(signal, pid) if pid > 1
    rescue Errno::ESRCH, Errno::ENOENT # process is already dead, cleanup files
      File.delete(Config::TMUX_FILE) if File.exists?(Config::TMUX_FILE)
      File.delete(Config::PID_FILE) if File.exists?(Config::PID_FILE)
    ensure
      true
    end
  end
end
