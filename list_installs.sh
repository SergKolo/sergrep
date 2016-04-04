print_usage()
{
  cat << EOF
Usage: list_installs.sh [-c] [-g]  [-u username] [-h]

The script parses authentication logs and filters 
installer actions based on whether they've been
done through gui, command-line, or particular 
user.

Installations done via gui tools typically use
polkit, so entries don't show exact item that
has been installed, only the tool used -
/usr/bin/software-center for example. Hence,
date-stamps still have to be cross checked with 
apt history logs
EOF

}
dump_logs()
{
  find /var/log/auth.log.*.gz | sort  -r | xargs zcat > "$1" 
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
