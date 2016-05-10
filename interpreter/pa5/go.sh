#!/bin/bash
TEST_FILE=$1
if [ -e $1-type ]; then
	rm $1-type
fi
cool --type $1
cool $1 > coolout
python main.py $1-type > output
vimdiff coolout output
diff -b -B -E -w coolout output
mv $1-type testcases/logs
