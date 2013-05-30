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
    [===                    ] 24:59

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

    set :timer, 25
    set :tmux, "~/.thyme-tmux"

    option :o, :open, 'opens today & records sheets' do
      `vim -O ~/.thyme-today.md ~/.thyme-records.md`
    end

    before do
      `tmux set status-interval 1`
    end

    after do
      `tmux set status-interval 60`
      `notify-send -u critical "0:00 - End of session"`
    end

The `set` method sets different configurations.  There are only two:

* `:timer` is the number of minutes to countdown from
* `:tmux` is the file to write out progress to for tmux integration

The `option` method adds new options to the `thyme` command.  In the above
example, we can now execute `thyme -o`.  Use `thyme -h` to see available
options.

The `before` and `after` adds hooks to our timer.  Now before the timer starts,
STDOUT will receive a message.  After the timer ends, vim will open our today
sheet.

Integration
===========

For tmux integration, make sure to set the `:tmux` option in `~/.thymerc`:

    set :tmux, "~/.thyme-tmux"

Then in your `.tmux.conf` file:

    set-option -g status-right '#(cat ~/.thyme-tmux)'
    set-option -g status-interval 1

For vim integration, I like to execute `thyme -d` to toggle the timer.  This only
works if you have tmux integration setup for the countdown:

    nmap <leader>t :!thyme -d
    nmap <leader>T :!thyme -s

TODO
====

* add config reader
* add config `set`
* add `set :timer`
* add `set :tmux`
* add tmux color and critical time threshold options
* add config `option`
* add config `before` and `after`
* add libnotify integration (?)
* figure out after hook with tmux set interval integration (hooks with arg?)
* figure out how to remove tmux file on stop (-d vs normal)
* look into alternatives for sleep (?)
* calculate time via delta instead of counter

License
=======

Copyright Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
