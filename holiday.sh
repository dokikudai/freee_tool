#!/bin/bash

find ./master/holiday/ -name "*.txt" \
  | while read -r text_file
    do
        cat ${text_file}
    done
