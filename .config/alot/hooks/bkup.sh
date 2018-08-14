#!/usr/bin/env bash

notmuch dump --gzip --output=$HOME/.mail/.notmuch/bkup/$(date "+%Y-%m-%d-%H:%M:%S").gzip
