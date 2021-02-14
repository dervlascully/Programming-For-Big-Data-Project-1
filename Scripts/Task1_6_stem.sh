#!/bin/bash

head -n 40 cleanRedditData.csv > copyData
file=copyData

	# diffs.txt contains the stemming replacements
cp diffs.txt stemming
	# each line is a word, multiple whitespaces, and the replacement word
	# replace the whitespace with a comma
sed -i 's/ *\b/,/g;s/^,//g;s/,$//g' stemming

	# a lot of the words and replacements are the same, remove these
while IFS= read -r line
do
	IFS=","
       	read -a lineArray <<< "$line"
		# if the word and replacement are different, write to new file
	if [[ "${lineArray[0]}" != "${lineArray[1]}" ]]
	then
		echo "$line" >> stemming2
	fi
done < stemming
F=stemming2

numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"
        # take the first line, which contains the column names

line="$(head -n 1 $file)"
        # read each column name from the first line into an array
IFS=","

read -a lineArray <<< "$line"
for (( i=0; i<$numColumns;i++)); do
                # if the ith element in the array is title
        if [[ "${lineArray[$i]}" == "title" ]]
        then
                cut -d"," -f$(($i+1)) $file > titleCol
                titleColNum=$(($i+1))
        fi
done

j=1
FILE=titleCol
while IFS= read -r line
do
	echo "$j"

	if [[ "$j" == "1" ]]
	then
		echo "$line" >> newColumn

	# if the line does not contains a url, apply stemming
        elif [[ "$line" != *"http"* ]]
        then
                text="$line"

		while IFS= read -r line
		do
		        IFS=","
		        read -a lineArray <<< "$line"
        		text="$(echo "$text" | sed "s/\b${lineArray[0]}\b/${lineArray[1]}/g")"

		done < $F
		echo "$text" >> newColumn

	# if the line contains at least 1 url
	else

                val="$(echo $line | sed  s/jpg/jpgS/g | sed s/wmv/wmvS/g)"
                IFS='S' read -r -a split <<< "$val"

                for element in "${split[@]}"
                do
                        if [[ "${element:0:4}" == "href" ]]
                        then
                                echo -n "$element" >> column

                        elif [[ "$element" =~ "http" ]]
                        then

                                # grep everything before the href (including href)
                                beforeUrl="$(echo $element | grep -oP '.*href')"
                                # remove the href from the end
                                beforeUrl="${beforeUrl::-4}"

                                # stem and write to file
                		text="$beforeUrl"
                		while IFS= read -r line
                		do
                        		IFS=","
                        		read -a lineArray <<< "$line"
                        		text="$(echo "$text" | sed "s/\b${lineArray[0]}\b/${lineArray[1]}/g")"

                		done < $F
                		echo -n "$text" >> column



                                # grep the url and write to file as is
                                Url="$(echo $element | grep -oP 'href\S*')"
                                echo -n "$Url" >> column

                        # else, no URL, apply stemming
                        else
                		text="$element"
                		while IFS= read -r line
                		do
                        		IFS=","
                        		read -a lineArray <<< "$line"
                        		text="$(echo "$text" | sed "s/\b${lineArray[0]}\b/${lineArray[1]}/g")"

                		done < $F
        	       		echo -n "$text" >> column



                        fi
                done

                # column is all one line as we used -n in echo, remove the extra whitespace and write to newColumn
		echo "$(head -n 1 column)" >> newColumn
                rm column # remove the column so that we are not appending to the same column again for the next  title that contains a url
        fi

	j=$(($j+1))
done < $FILE

rm stemming2
rm stemming

num=$titleColNum
awk -F"," 'FNR==NR{a[NR]=$1;next}{$ '"$num"'=a[FNR]}1' OFS="," newColumn $file > newFile

rm newColumn
