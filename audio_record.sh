#!/bin/bash
# Author: Serg Kolo
# Date: Dec 1, 2016
# Purpose: simple script for recording audio with arecord
# Written for: http://askubuntu.com/q/855893/295286

record_audio()
{
    # Set up some variables to control arecord here
    # Please remember to quote the variables
    # and pay attention to slashes in file paths
    
    filetype="wav"
    filename="record_$(date +%H_%M_%m_%d_%Y)"
    directory="$HOME/Music/recordings/"

    if ! [ -d "$directory" ];
    then
        mkdir "$directory"
    fi
    
    # This part will initiate recording of timestamped
    # please see arecord's man page for other options
    notify-send "Recording started"
    exec arecord -t "$filetype" "$directory""$filename"."$filetype"
}

main()
{
    if pgrep -f "arecord" ;
    then
       pkill -f "arecord" && notify-send "Recording stopped"
    else
       record_audio
    fi
}

main "$@"
