
#!/bin/bash
echo "Task: in the title column convert all characters to lower case and remove punctuation and stop words"

file="$1"


	# count the number of columns
numColumns="$(($(head -n 1 $file | grep -o ',' | wc -l)+1))"

        # take the first line, which contains the column names
line="$(head -n 1 $file)"

        # read each column name from the first line into an array
IFS=","
read -a lineArray <<< "$line"

	# extract the title column into the file titleColumn, and get the title column number
for (( i=0; i<$numColumns;i++)); do
                # if the ith element in the array is title
        if [[ "${lineArray[$i]}" == "title" ]]
        then
                cut -d"," -f$(($i+1)) $file > titleColumn
                titleColNum=$(($i+1))
	fi
done


# stopwords.txt has each word on a different line
# in the sed to remove stop words i need (word1|word2|....)
# so, replace every \n in stop words file with | and add () to start/end

# To do this using sed; create a label via :a
# append the current and next line to the pattern space via N
# if we are before the last line, branch to the created label $!ba ($! means not to do it on the last line as there should be one final newline).
# finally the substitution replaces every newline with a comma on the pattern space (which is the whole file)
# s/to be replaced/replacement, with to be replaced = \n, and replacement = |

# download stopwords.txt using wget
# wget http://astellar.com/downloads/stopwords.txt

cp stopwords.txt copyStopWords.txt
sed -i ':a;N;$!ba;s/\n/|/g' copyStopWords.txt
stopWords="($(head -n 1 copyStopWords.txt))"

	# print the number of rows and columns in the original file
echo "Before: "
. countColumns.sh $file
. countRows.sh $file

FILE=titleColumn

# convert all characters to lowercase in the title column using tr
cat $FILE | tr [:upper:] [:lower:]  > test
cp test $FILE

	# read the title column file line by line
	# we want to remove punctuation and stop words from the text
	# however, many of the title contain urls and we do not want to remove punctuation and stop words from these
while IFS= read -r line
do

		# check if the title contains a url by checking if it contains "http"

		# if the title does not contain a url
		# remove punctuation and stop words and write to new file newColumn

		# the punctuation is removed using tr

		# the stopWords file is of the form (word1|word2|word3| ..... ) from above
		# our sed is again of the form s/ want to replace / replacement
		# we are replacing stop words with ""
		# we are using \b which indicates a word boundary, as we only want to remove whole stop words
		# for example, "a" is a stop word, we don't want to remove every word containing the letter "a", just the word "a"
		# ie, every occurrence fo word boundary "a" word boundary

		# When we remove a word we are left with a space where the word was, for example "Peter's dog is brown" => "Peters dog  brown", with an extra
		# white space between dog and brown
		# use sed to replace every occurrence of 2 whitespaces with 1, and remove every occurrence of a whitespace at the beginning of a line

		# write the result to the file newColumn

	if [[ "$line" != *"http"* ]]
	then
		echo "$line" | tr -d '[:punct:]'| sed -E "s/\b$stopWords\b//g" | sed -E "s/  / /g" | sed -E "s/^ //g" >> newColumn


		# else, the title contains at least 1 url
	else

		# Each url ends with jpg or wmv
		# Add a character after each occurrence or jpg or wmv and split on that character

	       	# I have already converted all to lowercase
		# I will replace every occurrence of jpg or wmv with jpgS or wmvS, as I know that the character S will not already be in the string since it is uppercase
		# now, split on the character S into an array

		# now we know that each line in the split contains at most 1 url, as S only apprears at the end of each url


        	val="$(echo $line | sed  s/jpg/jpgS/g | sed s/wmv/wmvS/g)"
        	IFS='S' read -r -a split <<< "$val"

		# iterate through the array

        	for element in "${split[@]}"
        	do


                	# each element is of one of the following forms:

	                	# .... href__jpg/wmv, so text followed by url

	                	# href__jpg/wmv, element contains just the url

        	        	# ...., no url (last element)

                	# where ... is text that we want to remove punctuation and stop words from and href__jpg/wmv is a url

			# all will be written to a new file column (not the file newColumn as in the previous condition)


				# if the element starts with href we know that it is just the url
				# write to column file as is, without removing punctuation/stop words

				# using -n in echo as I don't want to echo the newline \n
	                if [[ "${element:0:4}" == "href" ]]
                	then
                        	echo -n "$element" >> column

	                        # else if it contains a url but has text before the url
	                        # We know from splitting that there will be nothing after the url

                        	# Remove punctuation and stop words from the text before the url and write to the column file
                	elif [[ "$element" =~ "http" ]]
                	then

				# grep everything before the href (including href)
                        	beforeUrl="$(echo $element | grep -oP '.*href')"

                                # remove the href from the end
                        	beforeUrl="${beforeUrl::-4}"

				# remove punctuation and stop words and write to file
                        	echo -n "$beforeUrl" | tr -d '[:punct:]' | sed -E "s/\b$stopWords\b//g" >> column

				# grep the url and write to file as is
                        	Url="$(echo $element | grep -oP 'href\S*')"
                        	echo -n " $Url" >> column


			# else, no URL, remove punctuation and stop words and write to the column file
                	else
                        	echo -n "$element" | tr -d '[:punct:]' | sed -E "s/\b$stopWords\b//g" >> column
                	fi
        	done

		# now "column" is the title from the current row with the stop words/punctuation removed from the text and the urls intact
		# column is all one line as we used -n in echo
		# remove the extra whitespace and write to newColumn (the file we wrote the titles which didn't contain urls to)
		echo "$(head -n 1 column | sed -E 's/  / /g' | sed -E 's/^ //g' )" >> newColumn

		rm column # remove the column so that we are not appending to the same column again for the next  title that contains a url
	fi
done < $FILE



num=$titleColNum

# the title column in the original file is "num"
# We want to replace the num th column in the original file with the first column in newColumn
# This is done in the exact same way as in Task1_4.sh script and the full detailed explanation can be found there
awk -F"," 'FNR==NR{a[NR]=$1;next}{$ '"$num"'=a[FNR]}1' OFS="," newColumn $file > newFile


cp newFile cleanRedditData.csv

# the number of rows and columns should be the same as before
echo "After: "
. countColumns.sh cleanRedditData.csv
. countRows.sh cleanRedditData.csv


rm newFile
rm newColumn
rm titleColumn
rm copyStopWords.txt
