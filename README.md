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

Usage: make sure Dianne Skoll's `remind` is intalled and that `remint.sh` is executable with `chmod +x /path/to/remint.sh`, then run with `./remint.sh /path/to/a/reminders/file`. `remint` will try to find a file in a default location if none is supplied as argument. I use it as a script executed in a new terminal window when clicking on the clock of my system bar.

[See short demo video here](demo/remint.mp4).

![](demo/shot0001.jpg)
![](demo/shot0002.jpg)
![](demo/shot0003.jpg)
![](demo/shot0004.jpg)
![](demo/shot0005.jpg)
![](demo/shot0006.jpg)

```
NAVIGATION
  , p  Previous page       t  Today
  . n  Next page           g  Go to
  h/l  -1/+1 day           q  Quit
  k/j  -1/+1 week      other  Quit with prompt
  M/m  -1/+1 month
  Y/y  -1/+1 year

VIEW
  w s  Toggle page span (4 weeks vs. full month)
    v  Toggle view (calendar vs. list)
    f  Toggle cell spacing (fixed vs. collapsed)
    i  Invert colors
    c  Toggle Remind colors
  : x  Toggle 24h format
    d  Toggle day of the year
    o  Show simple year overview
    ?  Show this help

DATA
    a  Add event at selection
    e  Edit data file
    b  Back up data

© 2022 Mathieu Laparie, <mlaparie@disr.it>, MIT license
```
