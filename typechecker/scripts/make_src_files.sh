#!/bin/bash
for i in *.cl2 ; do
  mv $i `basename $i .cl2`.cl ;
done
