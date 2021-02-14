#!/bin/bash

file="$1"


columnArray[0]="author_id"
columnArray[1]="author"
columnArray[2]="author_cakeday"
columnArray[3]="subreddit"
columnArray[4]="created_month"
columnArray[5]="id"
columnArray[6]="title"

numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"

input="$(head -n 1 $file)"


IFS=","
read -a lineArray <<< "$input"
for (( i=0; i<$numColumns;i++)); do

	for (( j=0; j<${#columnArray[@]}; j++ )); do
		if [[ "${lineArray[$i]}" == "${columnArray[$j]}" ]]
		then
			columnNumber[$j]=$i
			# echo "${lineArray[$i]}, $j, ${columnNumber[$j]}"
		fi
	done 
done

j=1
while IFS= read -r line
do
	if [[ "$j" != 1 ]]
	then
        	IFS=","
        	read -a lineArray <<< "$line"

		author_id="${lineArray[${columnNumber[0]}]}"
		author="${lineArray[${columnNumber[1]}]}"
		author_cakeday="${lineArray[${columnNumber[2]}]}"
		subreddit="${lineArray[${columnNumber[3]}]}"
		created_month="${lineArray[${columnNumber[4]}]}"
		id="${lineArray[${columnNumber[5]}]}"
		title="${lineArray[${columnNumber[5]}]}"
		#echo "$j $author_id, $author, $author_cakeday, $subreddit, $created_month, $id"

		mysql -h localhost -u root  --password="" -D "RedditDB" -e "insert into user values('$author_id', '$author', '$author_cakeday')"

		if [[ ! "${subredditArray[@]}" =~ "$subreddit" ]] 
		then
			mysql -h localhost -u root  --password="" -D "RedditDB" -e "insert into subreddit values('$subreddit')"
			subredditArray[$j]="$subreddit"
			echo "${subredditArray[$j]}"
		fi
		mysql -h localhost -u root  --password="" -D "RedditDB" -e "insert into post values('$id', '$author_id', '$subreddit', '$created_month', '$title')"
	fi
	j=$(($j+1))
done <  $file

