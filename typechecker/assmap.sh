#!/bin/bash
TEST_FILE="$1"

if [[ -e main.ml ]] ; then
  echo "---------------------- REFERENCE ------------------------"
  cool --type $TEST_FILE --out ref_${TEST_FILE%%.*}
  ocamlopt -o main.exe main.ml
  echo "---------------------- OUR FILE -------------------------"
  cool --parse $TEST_FILE
  ./main.exe $TEST_FILE-ast
  echo "---------------------- DIFF -----------------------------"
  diff -b -B -E -w ref_$TEST_FILE-type $TEST_FILE-type
  echo "---------------------------------------------------------"
  vimdiff ref_$TEST_FILE-type $TEST_FILE-type
fi
