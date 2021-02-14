#!/bin/bash

# Script to count the number of rows in a file passed in as argument

# take the first column of the file
cut -d"," -f1 $1 > file

# read the column line by line incrementing counter
j=0
while IFS= read -r line
do
        j=$(($j+1))
done < file
echo "Number of rows $j"
rm file
