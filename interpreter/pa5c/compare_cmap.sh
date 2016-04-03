#!/bin/bash
FNAME="$1"

if [ ! -f $FNAME ] ; then
	echo "File isn't in here or misspelled file name. Either way you're a dumbass"
	exit 1
fi

cool --class-map $FNAME
python main.py $FNAME-type > cmap_output.txt
diff $FNAME-type cmap_output.txt
vimdiff $FNAME-type cmap_output.txt


