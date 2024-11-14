#!/usr/bin/env zsh

autoload -Uz compinit

# Only check cache once a day
# https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done

compinit -C
