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

To interrupt the timer in daemon mode, simply run `thyme --stop`.  Or wait 25
minutes for it to kill itself.

Configure
=========

Thyme is configurable and extensible.  All configurations live in the
`~/.thymerc` file:

    set :timer, 25*60
    set :interval, 1
    set :tmux, true
    set:tmux_theme "#[fg=mycolor,bg=mycolor]#[fg=%s]%s#[fg=mycolor,bg=mycolor]"

    option :o, :open, 'open sheets' do
      `vim -O ~/.thyme-today.md ~/.thyme-records.md < \`tty\` > \`tty\``
    end

    before do
      `mplayer ~/music/flight-of-the-bumble-bee.mp3 &`
    end

    after do |seconds_left|
      `notify-send -u critical "Thymes Up!"` if seconds_left == 0
    end

The `set` method sets different configurations.  There are only two:

* `:timer` is the number of seconds to countdown from
* `:interval` is the refresh rate of the progress bar and tmux status in seconds
* `:tmux` is whether or not you want tmux integration on (off by default)

The `option` method adds new options to the `thyme` command.  In the above
example, we can now execute `thyme -o`.  Use `thyme -h` to see available
options.

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
    nmap <leader>T :!thyme -s<cr>

License
=======

Copyright Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
