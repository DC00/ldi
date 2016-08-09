#!/bin/bash
TEST_FILE="$1"
KEEP_DIFF="$2"

if [[ -e main.py ]] ; then
	echo "Testing $1"
	cool --lex $TEST_FILE
	cool --parse $TEST_FILE-lex --out ref_${TEST_FILE%%.*}
   	python main.py $TEST_FILE-lex
	echo "---------------------------------------------------- diff"
	diff -b -B -E -w ref_$TEST_FILE-ast $TEST_FILE-ast
	vimdiff $TEST_FILE-ast ref_$TEST_FILE-ast
	# rm ref_$TEST_FILE-ast $TEST_FILE-ast $TEST_FILE-lex
fi
