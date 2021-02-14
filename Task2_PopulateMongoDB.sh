
#!/bin/bash

f="$1"
# remove trailing ^M from the end of each row
sed -e "s/\r//g" $f > cleanRedditData2.csv
file=cleanRedditData2.csv

numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"

j=1
while IFS= read -r line
do
	# instantiate entry to empty string
	entry=""

	IFS=","

	# read the current line into the array lineArray, split by ","
	# lineArray will have an entry for each column with the column value for that row
	read -a lineArray <<< "$line"

	# if the current row is the first row read the column names into the array columnNames
	# the column names are the values in lineArray since it is the 1st row 
	if [[ "$j" == "1" ]]
	then
		# columnNames=("${lineArray[@]}") 
		for (( i=0; i<$(($numColumns));i++)); do
			columnNames[$i]="${lineArray[$i]}"
		done


	# else, it is not the first row
	# I want to loop through each column for this row and get the string column name : value for each value in the row, and append each of these to "entry"
	# For example, for row 2 I will have
		# author : 'Nakia-Armandina' ,
	# after the first itteration, and then append this to get
		# author : 'Nakia-Armandina' , author_flair_text : '&ampNews before it is news.' ,
	# and so on
		# author : 'Nakia-Armandina' , author_flair_text : '&ampNews before it is news.' , author_id : 'auth6xauxl' , brand_safe : 'FALSE', ...
	# with each column name and value for that row
	# values are surrounded by single quotes
	else

		# iterate through values
		for (( i=0; i<$numColumns;i++)); do

			# if the value is not empty
			if [[ "${lineArray[$i]}" != "" ]]
			then
				# add single quotes
				lineArray[$i]="'${lineArray[$i]}'"
				# append to entry
				entry="${entry}${columnNames[$i]} : ${lineArray[$i]} , "

			fi
		done

		# remove the trailing ", "
                entry="${entry::-2}"

		# write to the collection reddit in the mongo database RedditDB
                mongo  RedditDB --eval "db.reddit.insert({$entry})"


	fi


	j=$(($j+1))
done < $file
