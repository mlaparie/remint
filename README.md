```
                                                 88                ,d
                                                 °°                88     
     8b,dPPYba,   ,adPPYba,  88,dPYba,,adPYba,   88  8b,dPPYba,  MM88MMM
     88P°   °Y8  a8P_____88  88P°   °88°    °8a  88  88P°   '°8a   88
     88          8PP°°°°°°°  88      88      88  88  88       88   88
     88          °8b,   ,aa  88      88      88  88  88       88   88,    
     88           '°Ybbd8°°  88      88      88  88  88       88   °Y888
     
     A simple terminal UI wrapper for D. Skoll's Remind calendar program
```

`remint` is a simple wrapper script to add interactions and navigation to the terminal outputs of D. Skoll's [Remind scripting calendar program](https://salsa.debian.org/dskoll/remind).

## Usage
Make sure Dianne Skoll's `remind` is intalled and that `remint.sh` is executable with `chmod +x /path/to/remint.sh`, then run with `./remint.sh /path/to/a/reminders/file/or/directory` (if the argument is a directory, then `remint` will read from all `*.rem` files in it). `remint` will try default locations if none is supplied as argument, as well as the `DOTREMINDERS` environment variable. I use it as a script executed in a new terminal window when clicking on the clock of my system bar.

`remint` allows synchronizing to and from a git repository if you use `*.rem` files from a folder initialized as a git repository. Running `remint` on a single file supplied as CLI argument or on a data folder not containing files named as `<something>.rem` will not allow git synchronization; this is to limit the risk of synchronizing unwanted files. See git synchronization in action in the video below:

![](demo/remint_20230524_git.jpg)
[(Click here to watch video.)](demo/remint_20230524_git.mp4)

Other short demos of the features are available [here](demo/remint.mp4) (some base functions, initial version) and [here](demo/remint_2.mp4) (a few new functions in a later update).

![](demo/shot0001.jpg)
![](demo/shot0002.jpg)
![](demo/shot0003.jpg)
![](demo/shot0004.jpg)
![](demo/shot0005.jpg)
![](demo/shot0006.jpg)

## Configuration
`remint` options can be toggled from the TUI, but the defaults can be edited at the beginning of the script, or placed into a `remint.conf` file either alongside `remint.sh` (same directory) or in your Remind data directory (`~/.reminders`, `~/.config/remind`, or a folder set in `DOTREMINDERS`) to make them persist after updates:
```
DEFAULTFILE="100-remint.rem" # Default file to edit and add new events to if
			     # data path is a directory
COLOR="-@2"         # COLOR="" to disable, COLOR="-@1" for 256 colors only.
FORMAT="1"          # FORMAT="1" means 24h format, FORMAT="0" means am/pm.
VIEW="calendar"     # VIEW="list" to display the agenda by default.
COLORINVERTED="no"  # COLORINVERTED="yes" to toggle light/dark default mode.
SHOWDOYWOY="yes"    # SHOWDOYWOY="no" to hide day of year and week number.
WEEKSPAN="4"        # Number of weeks to show by default in week view.
MONTHSPAN="1"       # Number of months to show by default in month view.
PREFIX="+"          # If PREFIX="+", then the default view shows weeks,
                    # else if PREFIX="", then the default view shows months.
SPACING=""          # SPACING="" for fixed cell spacing (see `f` toggle),
		    # else SPACING=",n,m" where n and m are numbers.
MONDAYFIRST="m"     # MONDAYFIRST="" to start weeks on Sundays.
REMPAGER="less -Ri" # Or REMPAGER="$PAGER" to use your usual PAGER. Useful to
		    # search patterns or scroll long outputs. Beware that not
		    # all pagers can handle Remind's color and escape colors
                    # correctly; "less -Ri" can.
INFODURATION="1"    # Duration (in s) of displayed messages; the UI will be
                    # be unresponsive until info messages disappear.
AUTOSYNC="no"       # "yes" to automatically synchronize from and to git
                    # at startup (git pull) and when quitting (git push), else
                    #"no"; "yes" requires a reminders file in a git repository.
CUSTOM=""           # Add any extra Remind arguments you may need here.
```

## Help
```
NAVIGATION
  , p  Prev page          t  Today
  . n  Next page          g  Go to (yyyy, yyyymmdd, yyyy-mm-dd)
  h/l  -1/+1 day          o  Navigate from year overview
  k/j  -1/+1 week         q  Quit
  M/m  -1/+1 month    other  Quit with prompt
  Y/y  -1/+1 year

VIEW
    v  Toggle calendar/list views
  w s  Toggle week/month span modes
  [/]  Span -1/+1 week or month per page of current mode
    r  Reset default page span of current mode
    z  Toggle Monday/Sunday as first day of the week
  : x  Toggle 24h format
    d  Toggle day of the year and week number
    /  Pipe to pager (e.g. to search pattern, press h for help))
    f  Toggle fixed/collapsed cell spacing
    i  Invert terminal background and foreground colors
    c  Toggle Remind colors
  0-9  Adjust duration (in s) of temporary messages (e.g. git, back up)
    ?  Show this help

DATA
    a  Add event at selection
    e  Edit data file
    b  Back up data
    >  Push *.rem file(s) to git repository
    <  Pull *.rem file(s) from git repository

© 2023 Mathieu Laparie, <mlaparie@disr.it>, MIT license
```
