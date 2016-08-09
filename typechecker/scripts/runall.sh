#!/bin/bash
TEST_FILE="$1"

if [[ -e inject.py ]] ; then
  echo "Testing $1"
  cool --lex $TEST_FILE
  python inject.py $TEST_FILE-lex
  scripts/type_check.sh
  scripts/trashcan.sh
  scripts/unlex.sh
  scripts/make_src_files.sh
  scripts/final_check.sh
fi
