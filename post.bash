#!/bin/bash
Year=`date +%Y`
Month=`date +%m`
Day=`date +%d`


# $1 is title
# $2 is archetype
if [ -z "$1" ]; then
    echo "bash post.bash <title> <archetype>"
elif [ -z "$2" ]; then
    hugo new posts/$1/index.md
else
    hugo new posts/$1/index.md --kind $2  
fi