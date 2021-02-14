
#!/bin/bash
echo "Task: count the number of posts that have been made for each month"

file="$1"
        # count the number of columns
numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"

        # take the first line, which contains the column names
line="$(head -n 1 $file)"

        # read each column name from the first line into an array
IFS=","
read -a lineArray <<< "$line"

        # extract the created_month column into the file monthColumn
for (( i=0; i<$numColumns;i++)); do
                # if the ith element in the array is created_month
        if [[ "${lineArray[$i]}" == "created_month" ]]
        then
                cut -d"," -f$(($i+1)) $file > monthColumn

        fi
done

# j is row counter, initialised to 1
# count counts the number of unique month values, initialised to 0
j=1
count=0

# read the created_month column file line by line
while IFS= read -r line
do
	# if line 2
	# set the 0th element in monthArray to the current month value, and the 0th element in counArray to 1
	# this indicates 1 occurrence of this month value
	# increment count from 0 to 1 to indicate we have 1 unique month value so far
	if [[ "$j" == "2" ]]
	then
		monthArray[0]="$line"
		countArray[0]=1
		count=$(($count+1))

	# if line is not 1 or 2
	elif [[ "$j" != "1" ]]
	then
		# set variable found to false
		found=false

		# iterate through month array and check if current month is equal to any of the months in month array
		for (( i=0; i<${#monthArray[@]};i++)); do

			# if the current month equals the ith month in the month array
			# increment corresponding count and set found to true
			if [[ "${monthArray[$i]}" == "$line" ]]
			then
				countArray[$i]=$((${countArray[$i]}+1))
				found=true
			fi
		done
		# if found is still false we have a new month value that is not already in the month array
		# add this value to the count^th index of the month array, and set the corresponding countArray value to 1
		# increment count
		if [ $found == false ]
		then
			monthArray[$count]="$line"
			countArray[$count]=1
			count=$(($count+1))
		fi
	fi
	j=$(($j+1))
done < monthColumn

printf "\n"
echo "Month, Number of Posts:"
for (( i=0; i<${#monthArray[@]};i++)); do
	echo "${monthArray[$i]}, ${countArray[$i]}"
done
