#!/bin/bash
TEST_FILE="$1"

if [[ -e main.ml ]] ; then
  cool --class-map $TEST_FILE --out ref_${TEST_FILE%%.*}
  ocamlopt -o main.exe main.ml
  cool --parse $TEST_FILE
  ./main.exe $TEST_FILE-ast
  diff -b -B -E -w ref_$TEST_FILE-type $TEST_FILE-type
  vimdiff $TEST_FILE-type ref_$TEST_FILE-type
fi 
