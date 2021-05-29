#!/bin/bash
set -e

# Setup: sudo apt install inotify-tools

while true
do
    env/bin/python build.py || true
    inotifywait -e CLOSE_WRITE *.py css/*.css images/* mako-templates/*.mako
done
