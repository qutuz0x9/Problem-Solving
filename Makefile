# Thin wrapper: actual target logic lives in helpers/makefile.
#
# Targets:
#   make new PLATFORM=leetcode LANG=go NUM=0001 NAME=two-sum
#   make test [DIR=problems/leetcode/0001-two-sum]
#   make lint [DIR=problems/leetcode/0001-two-sum]
#   make bench [DIR=problems/leetcode/0001-two-sum]
#   make docs [FIX=1] [FILE=README.md]
#   make index

include helpers/makefile
