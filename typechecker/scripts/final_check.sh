#!/bin/bash
for i in *.cl ; do
  printf  $i ;
  printf " ";
  cool --type $i ;
done
echo
