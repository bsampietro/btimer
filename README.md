# Btimer

Btimer is a command line Ruby script to measure time. I did it as a simple way to be able to know how much time I have been working.


## Installation:

You don't need to do any installation, you can just run the main file. But if you want to run btimer from any directory,
the best way is to download the btimer.rb file and put it anywhere.
Then you can generate a symbolic link in your bin folder on your home (~/bin) like this:

``` bash
cd ~/bin
ln -s /path/to/btimer.rb t
```

Then you can run 't' from any directory.

## Options

``` bash
t
# if you just want to know what the current time count is

t set
# to set the timer in 00:00 and start it.

t stop
# to stop the timer

t start
# to restart the timer on the last stop, with the current time count

t set 1:25:00
# to set the timer to a specified time count

t add 15
# adds 15 minutes to the current time count

t sub 20
# substracts 20 minutes to the current time count
```

