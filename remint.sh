#!/usr/bin/env bash
# remint is a simple wrapper script to add interactions and navigation to
# the terminal outputs of D. Skoll's Remind scripting calendar program.
# Usage: ./remint.sh /path/to/a/reminders/file. remint.sh will try to find
# a file in a default location if none is supplied as argument.
#
# MIT License
# 
# Copyright © [2022] Mathieu Laparie <mlaparie [at] disr [dot] it>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Initialization
sleep 0.05 # Give the terminal some time to spawn if not already opened
REF=$(date "+%Y-%m-%d")

# Variables values below can be toggled from the TUI, those are default values
# The script has not been tested extensively with different defaults
DEFAULTFILE="100-remint.rem" # Default file to edit and add new events to if
			     # default data path is a directory
COLOR="-@2"         # COLOR="" to disable, COLOR="-@1" for 256 colors only
FORMAT="1"          # FORMAT="1" means 24h format, FORMAT="0" means am/pm
VIEW="calendar"     # Or VIEW="list" to display the agenda by default
COLORINVERTED="no"  # Or COLORINVERTED="yes" to toggle light/dark default mode
SHOWDOY="yes"       # SHOWDOY="no" to hide dat of year by default
WEEKSPAN="4"        # Number of weeks to show by default in week view
MONTHSPAN="1"       # Number of months to show by default in month view
PREFIX="+"          # If PREFIX="+", then the default view shows weeks,
                    # else if PREFIX="", then the default view shows months
SPACING=""          # SPACING="" for fixed cell spacing (see `f` toggle),
		    # else SPACING=",n,m" where n and m are numbers
MONDAYFIRST="m"     # Or MONDAYFIRST="" to start weeks on Sundays

# Functions
help() {
    clear
    tput cup $((((LINES/2))-18))
    printf "
$indent                                             88                ,d
$indent                                             °°                88     
$indent 8b,dPPYba,   ,adPPYba,  88,dPYba,,adPYba,   88  8b,dPPYba,  MM88MMM
$indent 88P°   °Y8  a8P_____88  88P°   °88°    °8a  88  88P°   '°8a   88
$indent 88          8PP°°°°°°°  88      88      88  88  88       88   88
$indent 88          °8b,   ,aa  88      88      88  88  88       88   88,    
$indent 88           '°Ybbd8°°  88      88      88  88  88       88   °Y888

$indent A simple terminal UI wrapper for D. Skoll's Remind calendar program


$indent NAVIGATION
$indent   \033[7m , p \033[0m  Previous page   \033[7m     t \033[0m  Today
$indent   \033[7m . n \033[0m  Next page       \033[7m     g \033[0m  Go to
$indent   \033[7m h/l \033[0m  -1/+1 day       \033[7m     q \033[0m  Quit
$indent   \033[7m k/j \033[0m  -1/+1 week      \033[7m other \033[0m  Quit with prompt
$indent   \033[7m M/m \033[0m  -1/+1 month
$indent   \033[7m Y/y \033[0m  -1/+1 year

$indent VIEW
$indent   \033[7m w s \033[0m  Toggle page span (4 weeks vs. full month)
$indent   \033[7m   v \033[0m  Toggle view (calendar vs. list)
$indent   \033[7m   f \033[0m  Toggle cell spacing (fixed vs. collapsed)
$indent   \033[7m   i \033[0m  Invert colors
$indent   \033[7m   c \033[0m  Toggle Remind colors
$indent   \033[7m : x \033[0m  Toggle 24h format
$indent   \033[7m   m \033[0m  Toggle Monday/Sunday as first day of the week
$indent   \033[7m   d \033[0m  Toggle day of the year
$indent   \033[7m   o \033[0m  Show simple year overview
$indent   \033[7m   ? \033[0m  Show this help

$indent DATA
$indent   \033[7m   a \033[0m  Add event at selection
$indent   \033[7m   e \033[0m  Edit data file
$indent   \033[7m   b \033[0m  Back up data

$indent © 2022 Mathieu Laparie, <mlaparie@disr.it>, MIT license
"
    read -rsn1
    case $REPLY in
        "I" | "i")
            invertcolors
            help
            read -rsn1 ;;
        *)
            ui ;;
    esac
}

page() {
    checkgeom
    tput civis
    unset REPLY
    if [[ "$COLORINVERTED" = "yes" ]]; then
        printf '\e[?5h'
    fi

    if [[ "${REF:0:4}" -lt "1990" ]]; then
        tput cup $((LINES-2)) 22
        printf "\033[7m !! \033[0m Error: years before 1990 are not supported by Remind."
        REF="1990-01-01"
        read -rsn1
    elif  [[ "${REF:0:4}" -gt "5990" ]]; then
        tput cup $((LINES-2)) 22
        printf "\033[7m !! \033[0m Error: years ofter 5990 are not supported by Remind. I know that frustration."
        REF="5990-12-31"
        read -rsn1
    fi
    
    clear
    if [[ "$VIEW" = "calendar" ]] && [[ "$PREFIX" = "+" ]]; then
        remind ${COLOR} -${MONDAYFIRST}cu${PREFIX}${WEEKSPAN} -b${FORMAT} \
            -w${COLS}${SPACING} ${INPUT} ${REF}
    elif [[ "$VIEW" = "calendar" ]] && [[ "$PREFIX" = "" ]]; then
        remind ${COLOR} -${MONDAYFIRST}cu${PREFIX}${MONTHSPAN} -b${FORMAT} \
            -w${COLS}${SPACING} ${INPUT} ${REF}
    elif [[ "$VIEW" = "list" ]] && [[ "$PREFIX" = "+" ]]; then
        printf "\033[7m Weeks $(date -d $REF '+%W') to $(date -d $REF+3weeks '+%W (%Y)') \033[0m\n\n"
        remind ${COLOR} -${MONDAYFIRST}s${PREFIX}${WEEKSPAN} -b${FORMAT} \
            ${INPUT} ${REF}
        printf "\n"
    elif [[ "$VIEW" = "list" ]] && [[ "$PREFIX" = "" ]]; then
        printf "\033[7m $(date -d $REF '+%B %Y') \033[0m\n\n"
        remind ${COLOR} -${MONDAYFIRST}s${PREFIX}${MONTHSPAN} -b${FORMAT} \
            ${INPUT} ${REF}
        printf "\n"
    fi
    
        tput cup $((LINES-2))
        if [[ "$SHOWDOY" = "yes" ]]; then
            DOY="($(date -d "$REF" "+%j"))"
            printf "\033[7m > \033[0m %s $DOY \n ?  Help" "$REF"
        else
            printf "\033[7m > \033[0m %s \n ?  Help" "$REF"
        fi
}

ui() {
    while true ; do
        page
        read -rsn1
        case $REPLY in
            "P" | "p" | ",")
                if [[ "$PREFIX" = "+" ]]; then
                    REF=$(date -d "$REF-$WEEKSPAN weeks" "+%Y-%m-%d")
                else
                    REF=$(date -d "$REF-$MONTHSPAN months" "+%Y-%m-%d")
                fi
                continue ;;
                   
            "N" | "n" | ".")
                if [[ "$PREFIX" = "+" ]]; then
                    REF=$(date -d "$REF+$WEEKSPAN weeks" "+%Y-%m-%d")
                else
                    REF=$(date -d "$REF+$MONTHSPAN months" "+%Y-%m-%d")
                fi
                continue ;;
            
            "Y")
                REF=$(date -d "$REF-1 year" "+%Y-%m-%d") && continue ;;
            
            "y")
                REF=$(date -d "$REF+1 year" "+%Y-%m-%d") && continue ;;
            
            "M")
                REF=$(date -d "$REF-1 month" "+%Y-%m-%d") && continue ;;
            
            "m")
                REF=$(date -d "$REF+1 month" "+%Y-%m-%d") && continue ;;
            
            "K"| "k")
                REF=$(date -d "$REF-1 week" "+%Y-%m-%d") && continue ;;
            
            "J" | "j")
                REF=$(date -d "$REF+1 week" "+%Y-%m-%d") && continue ;;
            
            "h"| "H")
                REF=$(date -d "$REF-1 day" "+%Y-%m-%d") && continue ;;
            
            "L" | "l")
                REF=$(date -d "$REF+1 day" "+%Y-%m-%d") && continue ;;
            
            "T" | "t")
                REF=$(date "+%Y-%m-%d") && continue ;;
            
            "V" | "v")
                if [[ "$VIEW" = "calendar" ]]; then
                    VIEW="list"
                else
                    VIEW="calendar"
                fi
                continue ;;
            
            "X" | "x" | ":")
                if [[ "$FORMAT" -eq "1" ]]; then
                    FORMAT=0
                else
                    FORMAT=1
                fi
                continue ;;
            
            "Z" | "z")
                if [[ "$MONDAYFIRST" = "m" ]]; then
                    MONDAYFIRST=""
                else
                    MONDAYFIRST="m"
                fi
                continue ;;
            
            "D" | "d")
                clear
                if [[ "$SHOWDOY" = "yes" ]]; then
                    SHOWDOY="no"
                else
                    SHOWDOY="yes"
                fi
                continue ;;
            
            "C" | "c")
                if [[ "$COLOR" = "-@2" ]]; then
                    COLOR=""
                else
                    COLOR="-@2"
                fi
                continue ;;
            
            "W" | "w" | "S" | "s")
                if [[ "$PREFIX" = "+" ]]; then 
                    PREFIX=""
                    SPACING=",0,0"
                else
                    PREFIX="+"
                    SPACING=""
                fi
                continue ;;
            
            "F" | "f")
                if [[ "$SPACING" = ",0,0" ]]; then
                    SPACING=""
                else
                    SPACING=",0,0"
                fi
                ui ;;
            
            "A" | "a")
                if [[ "$COLORINVERTED" = "yes" ]]; then
                    invertcolors
                    COLORINVERTED="yes"
                fi
                if [[ -v EDITOR ]]; then
                    case "$EDITOR" in
                        "kak")
                            kak "$FILE" -e "execute-keys oREM<space>$REF<space>"
                            ;;
                        "emacs")
                            emacs -nw +2 "$FILE" # How to insert $REF programmatically?
                            ;;
                        "vim")
                            vim +2 -c "put ='$REF '" -c "startinsert!" "$FILE"
                            ;;
                        "vi")
                            vi +2 "$FILE" # How to insert $REF programmatically?
                            ;;
                        "nano")
                            nano +2 "$FILE" # How to insert $REF programmatically?
                            ;;
                        *)
                            $EDITOR "$FILE"
                            ;;
                    esac
                elif type kak &> /dev/null; then
                    kak "$FILE" -e "execute-keys oREM<space>$REF<space>"
                elif
                    type emacs &> /dev/null; then
                    emacs -nw +2 "$FILE" # How to insert $REF programmatically?
                elif
                    type vim &> /dev/null; then
                    vim +2 -c "put ='$REF '" -c "startinsert!" "$FILE"
                elif
                    type vi &> /dev/null; then
                    vi +2 "$FILE" # How to insert $REF programmatically?
                else
                    type nano &> /dev/null
                    nano +2 "$FILE" # How to insert $REF programmatically?
                fi
                if [[ "$COLORINVERTED" = "yes" ]]; then
                    invertcolors
                    COLORINVERTED="yes"
                fi
                continue ;;
            
            "E" | "e")
                if [[ "$COLORINVERTED" = "yes" ]]; then
                    invertcolors
                    COLORINVERTED="yes"
                fi
                if [[ -v EDITOR ]]; then
                    $EDITOR "$FILE"
                elif type kak &> /dev/null; then
                        kak "$FILE"
                elif
                    type emacs &> /dev/null; then
                    emacs -nw "$FILE"
                elif
                    type vim &> /dev/null; then
                    vim "$FILE"
                elif
                    type vi &> /dev/null; then
                    vi "$FILE"
                else
                    type nano &> /dev/null
                    nano "$FILE"
                fi
                if [[ "$COLORINVERTED" = "yes" ]]; then
                    invertcolors
                    COLORINVERTED="yes"
                fi
                continue ;;
            
            "B" | "b")
                cp "$FILE" "$FILE"_backup_"$(date +'%Y%m%d_%H%M')" || err=1
                tput cup $((LINES-2)) 22
                if [[ "$err" -eq "1" ]]; then
                    printf "\033[7m >_ \033[0m Failed to back up data."
                else
                    printf "\033[7m >_ \033[0m Data successfully backed up."
                fi
                sleep 2 && ui ;;
            
            "/" | "G" | "g")
                goto
                continue ;;
            
            "O" | "o")
    	    overview ;;
            
            "I" | "i")
    	    invertcolors
    	    continue ;;
    	    
            "?")
                checkgeom
                help ;;

            "Q" | "q")
                tput cnorm && exit 0 ;;

            *)
                tput cup $((LINES-2)) 22
                printf "\033[7m >_ \033[0m Quit? [Y/n]"
                read -rsn1
                case $REPLY in
                    "Y" | "y" | "")
                        if [[ "$COLORINVERTED" = "yes" ]]; then
                            invertcolors
                            tput cnorm && exit 0
                        else
                            tput cnorm && exit 0
                        fi
                        ;;

                    *)
    		    continue ;;
    		    
                esac
                ;;

        esac
    done
}

overview() {
    clear
    cal -${MONDAYFIRST:-s}wy "${REF:0:4}" | center
    read -rsn1
    case $REPLY in
        "," | "Y" | "P" | "p")
            clear && cal -${MONDAYFIRST:-s}wy "$((${REF:0:4}-1))" | center
            REF=$(date -d "$REF-1 year" "+%Y-%m-%d")
            overview ;;
        "." | "y" | "N" | "n")
            clear && cal -${MONDAYFIRST:-s}wy "$((${REF:0:4}+1))" | center
            REF=$(date -d "$REF+1 year" "+%Y-%m-%d")
            overview ;;
        "/" | "G" | "g")
            clear && cal -${MONDAYFIRST:-s}wy "$((${REF:0:4}+1))" | center
            goto
            overview ;;
        "I" | "i")
            invertcolors
            overview ;;
        "Z" | "z")
            if [[ "$MONDAYFIRST" = "m" ]]; then
                MONDAYFIRST=""
            else
                MONDAYFIRST="m"
            fi
            overview ;;
        *)
            return ;;
    esac
}

goto() {
    tput cup $((LINES-2)) 22
    printf "\033[7m >_ \033[0m Go to year or date: "
    read -r
    tput cup $((LINES-2)) 22
    if [[ "$REPLY" = "" ]]; then
        REF=$(date "+%Y-%m-%d")
    elif ! [[ "${REPLY:0:4}" =~ ^-?[0-9]+$ ]]; then
        printf "\033[7m !! \033[0m Go to year or date: invalid format."
        read -rsn1
    elif [[ "${#REPLY}" -eq "4" && "${REPLY}" -ge "1990" && \
        "${REPLY}" -le "5990" ]]
    then
        TMP="${REF:6:10}"
        REF=$(date -d "$(date "+$REPLY-$TMP")" "+%Y-%m-%d")
    elif [[ "${REPLY:0:4}" -lt "1990" || "${REPLY:0:4}" -gt "5990" ]]; then
        printf "\033[7m !! \033[0m Go to year or date: Remind only supports years within [1990-5990]. We have 4000 years to make history."
        read -rsn1
    elif ! date -d "$REPLY" > /dev/null 2>&1; then
        printf "\033[7m !! \033[0m Go to year or date: invalid date."
        read -rsn1
    elif [[ $(date -d "$REPLY" "+%Y") -lt "1990" ]]; then
        printf "\033[7m !! \033[0m Go to year or date: invalid date."
        read -rsn1
    else
        REF=$(date -d "$REPLY" "+%Y-%m-%d")
    fi
    DOY="($(date -d "$REF" "+%j"))"
}

invertcolors() {
    clear
    if [[ "$COLORINVERTED" = "yes" ]]; then
        printf '\e[?5l'
	COLORINVERTED="no"
    else
        printf '\e[?5h'
	COLORINVERTED="yes"
    fi
}

center() {
  while IFS= read -r LINES
  do
    printf "%$(((COLUMNS+${#LINES})/2))s\n" "$LINES"
  done
}

checkgeom() {
    COLS=$(tput cols)
    LINES=$(tput lines)
    indent=$(printf '%*s' "$((((COLS/2))-36))")
}

# Execution
case "$1" in
    "")
	if [[ -n "$DOTREMINDERS" ]] && [[ -e "$DOTREMINDERS" ]]; then
         INPUT="$DOTREMINDERS"
        elif [[ -e "$HOME/.config/remind/reminders" ]]; then
            INPUT="$HOME/.config/remind/reminders"
        elif [[ -e "$HOME/.reminders" ]]; then
            INPUT="$HOME/.reminders"
        else
            printf "Error: no data file found. Provide one as argument or create one at '$HOME/.config/remind/reminders' or '$HOME/.reminders'. Those can also be directories containing multiple data files, in which case remint will add new events to ./%s by default. Press any key to quit." "$DEFAULTFILE"
            read -rsn1 && exit 1
        fi
	if [[ -d "$INPUT" && ! -f "$INPUT/100-remint.rem" ]]; then
            FILE="$INPUT/$DEFAULTFILE"
            printf ";; Events\n\n" > "$FILE"
#            for f in "$INPUT"/*; do
#            	[[ "$f" != "$FILE" && "$f" != *"_backup_"* && \
#            		"$f" != *".rem" && "$f" != *".purged" ]] && \
#                	printf ";; INCLUDE $f\n" >> $FILE
#            done
            page && tput cup $((LINES-2)) 22
            printf "\033[7m >_ \033[0m New data file created: %s" "$FILE"
            sleep 3
	elif [[ -d "$INPUT" && -f "$INPUT/100-remint.rem" ]]; then
            FILE="$INPUT/$DEFAULTFILE"
	elif [[ -f "$INPUT" ]]; then
            FILE="$INPUT"
	fi
	ui ;;
    
    "h" | "help" | "-h" | "--h" | "-help" | "--help")
        help && exit 0 ;;

    *)
        if [[ -f "$1" ]]; then
            INPUT="$1"
            FILE="$INPUT"
	elif [[ -d "$1" && ! -f "$1/100-remint.rem" ]]; then
            INPUT="$1"
            FILE="$INPUT/$DEFAULTFILE"
            printf ";; Events\n\n" > "$FILE"
#            for f in "$INPUT"/*; do
#            	[[ "$f" != "$FILE" && "$f" != *"_backup_"* && \
#            		"$f" != *".rem" && "$f" != *".purged" ]] && \
#                	printf ";; INCLUDE $f\n" >> $FILE
#            done
            page && tput cup $((LINES-2)) 22
            printf "\033[7m >_ \033[0m New data file created: %s" "$FILE"
            sleep 3
	elif [[ -d "$1" && -f "$1/100-remint.rem" ]]; then
                INPUT="$1"
                FILE="$INPUT/$DEFAULTFILE"
                echo $FILE
        else
            printf "Error: invalid data file. Press any key to quit."
            read -rsn1 && exit 1
        fi
        ui ;;
esac
