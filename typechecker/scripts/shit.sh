#!/bin/bash
FILENAME="$1"

if [[ -e inject.py ]] ; then
  cool --parse $FILENAME
  cool --out ref-${FILENAME%%.*} --type $FILENAME
  python main.py $FILENAME-ast
  diff -b -B -E -w $FILENAME-type ref-$FILENAME-type
fi
