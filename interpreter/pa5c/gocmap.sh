#!/bin/bash
if [ -e hello-world.cl-type ]; then
    rm hello-world.cl-type
fi
cool --class-map hello-world.cl
python main.py hello-world.cl-type
