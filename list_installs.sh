#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: April 4, 2016
# Purpose: filtering installation attempts
# Written for:
# Tested on:  Ubuntu 14.04 LTS
###########################################################
# Copyright: Serg Kolo , 2016
#    
#     Permission to use, copy, modify, and distribute this software is hereby granted
#     without fee, provided that  the copyright notice above and this permission statement
#     appear in all copies.
#
#     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
#     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#     DEALINGS IN THE SOFTWARE.

ARGV0="$0"
ARGC=$#
print_usage()
{
cat << EOF
Usage: list_installs.sh [-c] [-g]  [-u username] [-h]

The script parses authentication logs and filters 
installation attempts based on whether they've been
done through gui, command-line, or particular 
user. Note that it lists all attempts at authentica-
tion for software installation. It doesn't show
whether or not the installation succeeded.

Installations done via gui tools typically use
polkit, so entries don't show exact item that
has been installed, only the tool used -
/usr/bin/software-center for example. Hence,
date-stamps still have to be cross checked with 
apt history logs

Note that authentication logs (auth.log) are
rotated as outlined in /etc/logrotate.conf ,
typically every 4 weeks. This may need to be
tuned by your system's administrator to list
installs over longer periods of time
EOF

}
dump_logs()
{
  find /var/log/auth.log.*.gz | sort  -r -V | xargs zcat > "$1" 
  cat /var/log/auth.log >> "$1"
}

generate_report()
{
  awk '$0~/.*apt-get.*/||/.*dpkg.*/||/.*org\.debian\.apt\.install-or-remove-packages.*/\
       {print $0;print "- - -"}' "$1"  > /tmp/report.tmp
  mv /tmp/report.tmp "$1"
}

gui_installs()
{
  awk '$0~/org\.debian\.apt\.install-or-remove-packages/\
       { printf "%s %s %s ",$1,$2,$3;\
         for(i=4;i<=NF;i++){\
            if($i~/unix-user/){\
               printf " %s ",$i; };\
            if($i~/action/){\
              printf "%s\n",$(i+1); next  }\
         }\
       }' "$1"
}

cmd_installs()
{
  awk '$0~/.*apt-get.*/||/.*dpkg.*/{\
       printf "%s %s %s ",$1,$2,$3 ;\
       for(i=1;i<=NF;i++){\
          if($i~/sudo/||/pkexec/){\
             printf " %s ",$(i+1)};\
          if($i~/COMMAND/){\
            for(j=i;j<=NF;j++)\
               printf "%s ",$j\
          }\
       };
       printf "\n"  }' "$1"
}

parse_args()
{
 local OPTIND opt
 # no leading : means errors reported(which is what i want)
 # : after letter means options takes args, no letter - no args
 while getopts "cgu:h" opt
 do
   case ${opt} in
     c) cmd_installs "$DUMPFILE"
        ;;
     g) gui_installs "$DUMPFILE"
        ;;
     u) UNAME="${OPTARG}"
        echo ">>> CMD INSTALLS <<<"
        cmd_installs "$DUMPFILE" | grep $UNAME 
        echo ">>> GUI INSTALLS  <<<"
        gui_installs "$DUMPFILE" | grep $UNAME
        ;;
     h) print_usage
        ;;
    \?) echo "Invalid option: -$OPTARG" > /dev/stderr
        ;;
    esac
  done
  shift $((OPTIND-1))
}


main()
{
  local DUMPFILE="/tmp/auth.dump"
  dump_logs "$DUMPFILE"
  generate_report  "$DUMPFILE"
  parse_args "$@"  
  rm "$DUMPFILE"
}
main "$@"
