#!/bin/bash
# Purpose: Install useful softwares in Ubuntu after a fresh install of OS
# Author: Tharindu Lakshan Kumara
# ------------------------------------------

INPUT=packagelist.csv
IFS=',' # input file seperator

if test -f $INPUT > /dev/null; then
    echo "File exists"
    else
        echo "File does not exist"
        exit 99
fi