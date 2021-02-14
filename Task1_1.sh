#!/bin/bash

	# print task
echo "Task: Remove columns 1, 2, 3, 34"

	# input file is first argument
inputFile="$1"

	# the file I will use throughout is cleanRedditData.csv
outputFile=cleanRedditData.csv

	# copy file to output file
cp $inputFile $outputFile

	# print number of rows and columns (for checking purposes to ensure everything is done correctly)
	# To do this I have written the scripts countColumns.sh and countRows.sh which take in a file as argument and print the number of columns / rows
	# These are used throughout the scripts to print the number of columns/rows at the beginning and end of each script

echo "Before:"
. countColumns.sh $inputFile
. countRows.sh $inputFile

	# cut out from row 4 to row 33, and row 35 to the end
	# the ouput file is now the original file with rows 1, 2, 3 and 34 removed
cut -d"," -f 4-33,35- $outputFile > temp.csv

	# copy to output file
cp temp.csv $outputFile
rm temp.csv

	# print rows and columns again, the number of rows should be the same as before, and there should be 4 less columns

echo "After:"
. countColumns.sh $outputFile
. countRows.sh $outputFile
