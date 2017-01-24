#!/usr/bin/env bash

is_self(){

    if [ "$link" == "/bin/bash" ] &&  grep -q $0 /proc/$proc_pid/cmdline
    then
        return 0
    else
        return 1
    fi
    
}

find_process(){
     local function_pid=$$

     find /proc -maxdepth 1 -type d -path "*/[1-9]*" | while read -r proc_dir;
     do
         local proc_pid=$(basename "$proc_dir")
         local link=$(readlink -e "$proc_dir"/exe)

         if is_self ; then continue ; fi

         if [ "$link" == "$1"   ]
         then
              terminal=$( readlink -e "$proc_dir/fd/0" )
              printf "%s\t%s\t%s\t" "$proc_pid" "$1" "$terminal"
              stat --printf="%U\n" "$proc_dir"/mountstats 
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
