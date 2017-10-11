#!/bin/sh

# usage: make a soft link in your PATH to this file: 
#     ln -s ~/git/scratchpad/aws_cloudformation/cfn-visualize.sh ~/bin/cfn-visualize
#
# note: you will also need to do the same to the cfviz.py.  See cfviz.py for 
#
# prerequisites: graphviz + imagemagick

[ -n "$1" ] || exit 1
[ -f "$1" ] && cat "$1" | cfviz | dot -Tsvg -o/tmp/output.svg
[ -f "/tmp/output.svg" ] && convert /tmp/output.svg "$1".png && rm -f /tmp/output.svg
