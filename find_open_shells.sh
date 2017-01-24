#!/usr/bin/env bash

is_self(){

    if [ "$link" == "/bin/bash" ] &&  grep -q $0 /proc/$proc_pid/cmdline
    then
        return 0
    else
        return 1
    fi
    
}
print_proc_info(){
     terminal=$( readlink -e "/proc/$proc_pid/fd/0" )
     [ -z "$terminal"  ] && terminal=$'\t'
     printf "%s\t%s\t%s\t" "$proc_pid" "$1" "$terminal"
     stat --printf="%U\n" /proc/"$proc_pid"/mountstats 
}

find_process(){
     local function_pid=$$

     local search_base=$(basename "$1")

     find /proc -maxdepth 1 -type d -path "*/[1-9]*" | while read -r proc_dir;
     do
         local proc_pid=$(basename "$proc_dir")
         local link=$(readlink -e "$proc_dir"/exe)
         local name=$( awk 'NR==1{print $2}' "$proc_dir"/status  2>/dev/null )

         if is_self ; then continue ; fi

         if [ "$link" == "$1"   ] ||
            [ -z "$link"  ] && [ "$name" = "$search_base"  ]
         then
             print_proc_info $1
         # make additional check if readlink wasn't allowed to 
         # get where /proc/[pid]/exe is symlinked
         
         fi
     done
     
}

main(){
    while read -r shell
    do
        find_process "$shell" 
    done < /etc/shells 

    echo "Done, press [ENTER] to continue"
    read
}

main 
