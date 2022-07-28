#!/bin/bash
IFS=$'\n'

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    rm $d_file_path

    echo "Remove current conversion file and exiting"
    exit 130
}


help(){
    printf "usage: $0 [options] <source path> <destination path> \n"
    printf "options:\n -h     Show this screen. \n -v     Verbose output. \n -d     Dry run - Execute everyhting except the ffmpeg conversion."
    exit 0
}
level=2                                                                       #default level executes whole script
while getopts hvd: flag
do
    case "${flag}" in
        v) v='-v';; #verbose mode
        h) help;;
        d) level=0;; #dry run, make directories but do not convert files
    esac
done

args=${#}
#if [ "$#" -ne 2 ]; then
#  help
#fi

s_dir="${@:(-2):1}" #get second last param
d_dir="${@: -1}"    #get last param

if [[ ! -d $s_dir ]]
then
    echo "Source directory not found."
    echo "Exiting..."
    exit 2
fi

if [[ ! -d $d_dir ]]
then
    echo "Distination directory not found."
    echo "Creating directory"
    mkdir -p $d_dir
fi


abs_s_path=$(cd "$(dirname "$s_dir")"; pwd)/$(basename "$s_dir")                  #get absolute path of source dir
abs_d_path=$(cd "$(dirname "$d_dir")"; pwd)/$(basename "$d_dir")
echo "Converting all music in $abs_s_path, placing in $abs_d_path"


for f in $( find $s_dir -iname "*.flac");
do s_file_path=$f;                                                                   #path to found file
    echo "Checking: ${f#$abs_s_path/}"
    
    rel_s_path="${s_file_path#$abs_s_path}"                                             #strip all parents of source directory
    d_path=$d_dir/${rel_s_path#*/};                                                #generate path for file to be written to
    d_file_path=${d_path%.*}.mp3;                                                    #strip old fildname, append .mp3
    
    
    if test -f "$d_file_path"; then                                                  #check if file already exists
        echo "$FILE exists."
        continue                                                                #and skip if it does
    fi
    echo "Converting to:" $d_file_path
    mkdir -p $v ${d_file_path%/*}                                                    #make directory (including parents) to new file
    
    if [ $level != 0 ]; then                                                    #if dryrun not specified
        converting=1;
        ffmpeg -i $s_file_path -ab 320k -map_metadata 0 -id3v2_version 3 $d_file_path;
        converting=0;
    fi
done

