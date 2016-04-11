#!/bin/bash
TEST_FILE=$1
if [ -e $1-type ]; then
	rm $1-type
fi
cool --type $1
python main.py $1-type
