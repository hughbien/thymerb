Description
===========

Thyme is a console pomodoro timer.

Installation
============

    $ gem install thyme

Usage
=====

Start thyme with:

    $ thyme
    [=                                        ] 24:59

You'll have 25 minutes by default.  `Ctrl-C` to interrupt.  You can also start
it in daemon mode, which is only useful if you've got tmux integration to notify
you of the timer:

    $ thyme -d

To interrupt the timer in daemon mode, run `thyme` again.  Or wait 25 minutes
for it to kill itself.

Configure
=========

Thyme is configurable and extensible.  All configurations live in the
`~/.thymerc` file:

    set :timer, 25*60
    set :timer_break, 5*60
    set :warning, 5*60
    set :warning_color, "red,bold"
    set :interval, 1
    set :tmux, true
    set :tmux_theme, "#[fg=mycolor,bg=mycolor]#[fg=%s]%s#[fg=mycolor,bg=mycolor]"

    option :t, :today, 'open today sheet' do
      `vim -O ~/.thyme-today.md ~/.thyme-records.md < \`tty\` > \`tty\``
    end

    option :s, 'seconds num', 'run with custom seconds' do |num|
      @timer = num.to_i
      run
    end

    before do
      `mplayer ~/music/flight-of-the-bumble-bee.mp3 &`
    end

    after do |seconds_left|
      `notify-send -u critical "Thyme's Up!"` if seconds_left == 0
    end

The `set` method sets different configurations.

* `:timer` seconds to countdown from
* `:timer_break` seconds to countdown from in break mode
* `:warning` seconds threshold before tmux timer turns red (use 0 to disable)
* `:warning_color` color of the tmux timer during the warning period
* `:interval` refresh rate of the progress bar and tmux status in seconds
* `:tmux` whether or not you want tmux integration on (false by default)
* `:tmux_theme` optionally lets you format the tmux status

The `option` method adds new options to the `thyme` command.  In the above
example, we can now execute `thyme -b` or `thyme -t`.  Use `thyme -h` to see
available options.

The `before` and `after` adds hooks to our timer.  Now before the timer starts,
an mp3 will play.  After the timer ends, a notification will be sent.

Integration
===========

For tmux integration, make sure to set the `:tmux` option in `~/.thymerc`:

    set :tmux, true

Then in your `.tmux.conf` file:

    set-option -g status-right '#(cat ~/.thyme-tmux)'
    set-option -g status-interval 1

For vim integration, I like to execute `thyme -d` to toggle the timer.  This only
works if you have tmux integration setup for the countdown:

    nmap <leader>t :!thyme -d<cr>

Plugins
=======

Thyme's functionality can also be extended with plugins.  They'll usually follow this
format:

    require "thyme_growl"
    use ThymeGrowl, text: "Go take a break!"

You can create your own plugins.  They implement these methods:

    class MyThymePlugin
      def initialize(thyme, options={})
        # `thyme` is an instance of Thyme (see lib/thyme.rb)
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
    end

The `before`, `tick`, and `after` methods are all optional.

TODO
====

* refactor
* extract tmux, progressbar to plugin
* update website for breaks, break color, hooks, pause, repeat

License
=======

Copyright Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
