# Task : remove empty column
# initialise an array with a 0 for every column
# read each row, for each entry if it is non-empty set the corresponding array element for that column to 1
# after going through each row, remove any columns where the corresponding element in the array is still 0
# a non-empty value would have set these array values to 1, so a value of 0 => all empty values

#!/bin/bash

echo "Task: Remove empty columns"

	# input file
file="$1"

	# count the number of columns.
	# this is equal to the number of commas + 1
	# take just the first column (head), find all the occurrences of commas (grep), count the commas (wc), + 1
numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"

	# print the number of columns and rows before
echo "Before:"
echo "Number of Columns $numColumns"
. countRows.sh $file

        # Initialise an array and with all 0s
	# Number of elements = Number of columns
declare -a MY_ARRAY

for (( i=1; i<=$numColumns;i++)); do
       MY_ARRAY[$i]=0
done


input=$file


        # read the input file line by line
	# j is the current row number, initialised to 1
j=1

while IFS= read -r line
do
		# split the current row into an array, with "," as the delimiter
        IFS=","
        read -a lineArray <<< "$line"

		# iterate from [0 - Number of columns) to iterate through the line array
        for (( i=0; i<$numColumns;i++)); do

			# if the current row is not row 1, and the current row element is not empty
			# set the ith element in the array (initialised above to 0) to 1
			# this indicates that the ith row contains at least one non-empty value
                if [ $j -ne 1 ] && [ -n "${lineArray[$i]}" ]
                then
                        MY_ARRAY[$(($i + 1))]=1
                fi
        done

	# incrememnt row counter
        j=$(($j + 1))
done < $file


# the array columnsToRemove will contain the numbers of the columns to remove
# for example, columnsToRemove = [1, 5, 12, 17] => the rows 1, 5, 12, 17 are to be removed
# Loop through the array with 1 and 0 values from above
# if the ith value is 0 set the value of the next available element in the columnsToRemove array to i
# this indicates that the column i needs to be removed
declare -a columnsToRemove

# string which I will append with the column numbers to be removed and echo
columnsRemoved="Columns Removed: "

j=0
for (( i=1; i<=$numColumns;i++)); do
        if [ ${MY_ARRAY[$i]} -eq 0 ]
        then
                columnsToRemove[$j]=$(($i))
                j=$(($j+1))
		columnsRemoved="${columnsRemoved} $i"
        fi

done

numColumnsToRemove=$j
echo "Number of columns to be removed $numColumnsToRemove"



removed=0
for (( i=0; i<$numColumnsToRemove;i++)); do

        column=$((${columnsToRemove[$i]}-$removed))

	# if the column to be removed is the 1st column simply cut from column 2 to the last column
        if [[ "$column" == "1" ]]
        then
         	cut -d"," -f2- $file > temp.csv 
		cp temp.csv $file
		rm temp.csv
                removed=$(($removed+1))

	# else
	# cut all columns as far as the i-1 th column, then cut from the i+1 th column to the last column
        else
                x=$(($column-1))
                y=$(($column+1))
                cut -d"," -f-$x,$y- $file > temp.csv 
                cp temp.csv $file
                rm temp.csv
                removed=$(($removed+1))

        fi
done

echo "$columnsRemoved"

# print number of rows and columns after
# number of rows should be the same
# number of columns should be the number of columns before - the number of columns to be removed as echoed above
echo "After:"
. countColumns.sh $file
. countRows.sh $file
