
#!/bin/bash

echo "Task: Remove columns with the same value in every row"

file="$1"

	# count the number of columns as before and print the number of rows and columns
numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"
echo "Before:"
echo "Number of Columns $numColumns"
. countRows.sh $file

        # As in the previous script, Task1_2.sh, initialise an array with all 0s, one for each column
declare -a FLAG_ARRAY
for (( i=1; i<=$numColumns;i++)); do
        FLAG_ARRAY[$i]=0
done

	# declare the array values array without initialising
declare -a VALUES_ARRAY

input=$file

	# as before, read the file line by line
	# j = current row number, initialised to 1

j=1
while IFS= read -r line
do

		# split the line into an array using comma delimiter for the split
        IFS=","
        read -a lineArray <<< "$line"

		# iterate from (0 - number of columns]
        for (( i=0; i<$numColumns;i++)); do

		# if the current row is the second row
		# set the value for the ith element in the value array (declared above) to the ith line value
                if [[ "$j" == "2" ]]
                then
                        VALUE_ARRAY[$(($i+1))]=${lineArray[$i]}

		# if the line is not the 1st row or the 2nd row
		# check if the ith value in the line array is equal to the ith value in the value array as set above for row number == 2
		# if the values are not the same then we know that the column does not contain all of the same value
		# so, set the value in the flag array to 1
                elif [[ "$j" != "1" ]]
                then

                        if [[ "${VALUE_ARRAY[$(($i+1))]}" != "${lineArray[$i]}" ]]
                        then
                                FLAG_ARRAY[$(($i+1))]=1
                        fi
                fi
        done
        j=$(($j+1))

done < $file

# after iterating through all of the lines, the flag array should now be set to 1 for any column that contains at least 2 different values
# thus a 0 => it contains all the same values and must be removed


# as with the previous script, loop through the values in the flag array
# if the ith value is 0, set the next available element in the columnsToRemove array to i
j=0
columnsRemoved="Columns to remove: "
for (( i=1; i<=$numColumns;i++)); do
        if [ ${FLAG_ARRAY[$i]} -eq 0 ]
        then
                columnsToRemove[$j]=$(($i))
                j=$(($j+1))
		columnsRemoved="${columnsRemoved} $i"
        fi

done
echo "Number of columns to remove $j"
numColumnsToRemove=$j

# loop from (0 -  the number of columns to be removed] and remove the columns
removed=0
for (( i=0; i<$numColumnsToRemove;i++)); do

	# column to remove = column number from array - number of columns already removed
	# if we need to remove columns 1 and 3, then we will first remove column 1
	# then to remove column 3 we actually need to remove column 2 as with the first column removed the 3rd becomes the second
	# we are removing the columns in ascending order so this works
        column=$((${columnsToRemove[$i]}-$removed))

	# if the column to remove is column 1, cut from column 2
        if [[ "$column" == "1" ]]
        then
                cut -d"," -f2- $file > temp.csv 
                cp temp.csv $file
                rm temp.csv
                removed=$(($removed+1))

	# else, cut as far as the i-1 th column, and from the i+1 th column
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

echo "After:"
. countColumns.sh $file
. countRows.sh $file
