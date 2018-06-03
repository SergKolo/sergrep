#!/usr/bin/env bash
set -e

print_usage(){

cat <<EOF
Usage: sudo mklimdir.sh -m <Mountpoint Directory> -f <Filesystem> -s <INT>

-m directory
-f filesystem type (one of supported by mke2fs)
-s size in bytes
-h this message

Exit statuses:
0:
1: Invalid option
2: Missing argument
3: No args
4: root privillege required
EOF
} > /dev/stderr

parse_args(){
    #set -x

    option_handler(){

        case ${opt} in
            m) mountpoint=$( realpath -e "${OPTARG}" );;
            s) size=${OPTARG} ;;
            h) print_usage; exit 0 ;;
            f) mkfs_cmd=mkfs."${OPTARG}" ;;
            \?) echo ">>>Invalid option: -$OPTARG" > /dev/stderr; exit 1;;
            \:) echo ">>>Missing argument to -${OPTARG}" > /dev/stderr; exit 2;;
        esac
    }

    local OPTIND opt
    getopts "m:s:f:h" opt || { echo "No args passed">/dev/stderr;print_usage;exit 3;}
    option_handler 
    while getopts "m:s:f:h" opt; do
         option_handler
    done
    shift $((OPTIND-1))

}


main(){

    if [ $EUID -ne 0 ]; then
        echo ">>> Please run the script with sudo/as root" > /dev/stderr
        exit 4
    fi

    local mountpoint=""
    local size=0
    local mkfs_cmd

    parse_args "$@"
    quota_fs=/"${mountpoint//\//_}"_"$(date +%s)".quota
    dd if=/dev/zero of="$quota_fs" count=1 bs="$size"
    "$mkfs_cmd" "$quota_fs"
    mount -o loop,rw,usrquota,grpquota "$quota_fs" "$mountpoint"

    chown $SUDO_USER:$SUDO_USER "$mountpoint"

}

main "$@"
