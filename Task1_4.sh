

#!/bin/bash
echo "Task: seconds since epoch to month in the columns created_utc and retrieved_on"

file="$1"

numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"

echo "Before: "
. countColumns.sh $file
. countRows.sh $file

        # take the first line, which contains the column names
line="$(head -n 1 $file)"

        # read each column name from the first line into an array (split the line on the comma delimiter)
IFS=","
read -a lineArray <<< "$line"



	# iterate from (0 - the number of columns]
for (( i=0; i<$numColumns;i++)); do

                # if the ith element in the array is created_utc or retrieved_on
                # cut just that column into a seperate file
		# the files are old_created_utc, which contains just the created_utc column
		# and old_retrieved_on which contains just the retrieved_on column

        if [[ "${lineArray[$i]}" == "created_utc" ]]
	then
		cut -d"," -f$(($i+1)) $file > old_created_utc
		num1=$(($i+1))


	elif [[ "${lineArray[$i]}" == "retrieved_on" ]]
	then
		cut -d"," -f$(($i+1)) $file > old_retrieved_on
		num2=$(($i+1))
        fi
done



# now we have 2 files containing just the created_utc column and retrieved_on column

	# for created_utc column
	# read the file line by line
	# each line contains the value of created_utc for that row
input=old_created_utc
j=1
while IFS= read -r line
do
	# if row 1, the value is the column name, "created_utc". Echo this value to the new file newColumn
        if [ $j -eq 1 ]
        then
                echo "created_month" > newColumn
        # if the row is not row 1, convert the value from  seconds since epoch -> month and write to the new file
	# -d = display time described by STRING
	# %B = locale's full month name (e.g., January)
	else
                echo "$(date -d @"$line" +'%B')" >> newColumn
        fi

	# increment row counter
        j=$(($j + 1))

done < $input

# swap the old created_on column in the file with the new  column using awk
# num1 is the column number of created_on (initialised at the beginning of the script when cutting the created_on column)
# we want to swap the num1th column in the original file with the 1st column in the newColumn file
# to do this I used awk, the full eplanation of how it works is below

awk -F"," 'FNR==NR{a[NR]=$1;next}{$ '"$num1"'=a[FNR]}1' OFS="," newColumn $file > newFile
cp newFile $file
rm newFile

# -F"," specifies the comma delimiter

# FNR and NR are numbers initialised to 1 which refer to the current line numbers.
# FNR is the line number of the current file and incremements for each row, but is reset to 1 
# for the second file. 
# NR also increments for each row in the first file, but continues to increment without being
# reset for the second file

# FNR==NR allows you to work with one entire file at a time as it is only true when working
# with the first file

# First we are working with the newColumn file

# When working with the first file newColumn NR and FNR are initialised to 1 and both
# incremented for each row so FNR==NR is true while we work with the first file

# While we are working with the new column file we are creating an array called 'a' using line number (NR) as the key and first column ($1) as the value.

# The next inside the block means any further commands are skipped, so they are only run on the second file (not the new column file)

# Once the newColumn file ends, we move on to the original file we want to replace the column in.
# NR==FNR condition is now false as NR continues to increment whereas FNR is reset to 1
# So only second action block {$ '"$num1"'=a[FNR]} will be worked upon.

# Here, the values in the num1 th column of the second file are set to array initialised above (i.e. the values in the newColumn file)

# The 1 at the end prints the line. It returns true, and in awk true statements results in printing of the line.

# newColumn $file is the order the files are worked on. Since we want to create an array from the file newColumn we put that first.



# next repeat for retrieved_on
# this is the exact same so could equally be done using a loop with 2 iterations, using the first file and column number on the first iteration, and the 2nd on the 2nd

input=old_retrieved_on
j=1
while IFS= read -r line
do
        if [ $j -eq 1 ]
        then
                echo "$line" > newColumn
        else

                echo "$(date -d @"$line" +'%B')" >> newColumn
        fi
        j=$(($j + 1))

done < $input

awk -F"," 'FNR==NR{a[NR]=$1;next}{$ '"$num2"'=a[FNR]}1' OFS="," newColumn $file > newFile
cp newFile $file
rm newFile


. countColumns.sh $file
. countRows.sh $file

rm newColumn
rm old_retrieved_on
rm old_created_utc
