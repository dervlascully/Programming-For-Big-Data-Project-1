#!/bin/bash

# script which prints the number of columns in a file passed in as argument

file=$1

# take the first row and count the number of commas + 1
numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"
                # Take the first column
                # Split about each ","
                # count the number of lines

echo "Number of Columns $numColumns"
