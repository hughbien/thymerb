# Description

Thyme is a console pomodoro timer.

# Installation

    $ gem install thyme

# Usage

Start thyme with:

    $ thyme
    [=                                        ] 24:59

You'll have 25 minutes by default. `Ctrl-C` to interrupt. You can also start
it in daemon mode, which is only useful if you've got tmux integration to notify
you of the timer:

    $ thyme -d

Some other useful commands:

    $ thyme           # run again to pause/unpause
    $ thyme -s        # stops daemon
    $ thyme -d -r     # repeats timer until you manually stop it
    $ thyme -d -r 10  # repeats timer exactly 10 times

# Configure

Configurations live in the `~/.thymerc` file:

    set :timer, 25*60              # 25 minute pomodoros
    set :timer_break, 5*60         # 5 minute breaks
    set :warning, 5*60             # show warning color in tmux at <5 minutes, 0 to disable
    set :warning_color, 'red,bold' # warning color for tmux is red/bold
    set :break_color, 'blue'       # break color is blue
    set :interval, 1               # refresh timer every 1 second
    set :tmux, true                # turn on tmux integration
    set :tmux_theme, "#[fg=mycolor,bg=mycolor]#[fg=%s]%s#[fg=mycolor,bg=mycolor]"

    # adds `-t --today` option, which opens a text file in vim
    option :t, :today, 'open today sheet' do
      `vim -O ~/.thyme-today.md ~/.thyme-records.md < \`tty\` > \`tty\``
    end

    # adds `-s --seconds num` option, which allows on the fly timer
    option :s, 'seconds num', 'run with custom seconds' do |num|
      set :timer, num.to_i
      @run = true
    end

    # execute hook before thyme program starts
    before(:all) do
      `mplayer ~/music/flight-of-the-bumble-bee.mp3 &`
    end

    # execute hook before each pomodoro
    before do
      `terminal-notifier -message "Let's get started!"`
    end

    # execute hook after each pomodoro
    after do |seconds_left|
      `terminal-notifier -message "Thyme's Up!"` if seconds_left == 0
    end

    # execute hook after thyme program quits
    after(:all) do
      `mplayer ~/music/victory.mp3 &`
    end

# Tmux

For tmux integration, make sure to set the `:tmux` option in `~/.thymerc`:

    set :tmux, true

Then in your `.tmux.conf` file:

    set-option -g status-right '#(cat ~/.thyme-tmux)'
    set-option -g status-interval 1

For vim integration, I like to execute `thyme -d` to toggle the timer. This only
works if you have tmux integration setup for the countdown:

    nmap <leader>t :!thyme -d<cr>

# Plugins

Thyme's functionality can also be extended with plugins. They'll usually be installed
in `~/.thymerc` like this:

    require 'thyme_growl'
    use ThymeGrowl, text: 'Go take a break!'

You can create your own plugins. They implement these methods:

    class MyThymePlugin
      def initialize(thyme, options={})
        # `thyme` is an instance of Thyme::Config (see lib/thyme/config.rb)

        # adds `-t --today` option, which opens a text file in vim
        thyme.option :t, :today, 'open today sheet' do
          `vim -O ~/.thyme-today.md ~/.thyme-records.md < \`tty\` > \`tty\``
        end
      end

      def before_all
        # code to run when thyme starts up
      end

      def before
        # code to run when timer starts
      end

      def tick(seconds_left)
        # code to run each tick
      end

      def after(seconds_left)
        # code to run when timer stops
      end

      def after_all
        # code to run when thyme program ends
      end
    end

The `before_all`, `before`, `tick`, `after`, and `after_all` methods are all optional.

# License

Copyright Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
