#!/bin/bash

# script to run all task 1 scripts

echo "PART 1"
printf "\n"

	# I am taking a subset of the data, the first 15,000 lines, as it was very slow with the full amount of data
head -n 15000 reddit_2021.csv > subsetOfData

	# run script 1
. Task1_1.sh subsetOfData

printf "\n"
echo "PART 2"
printf "\n"

	# run script 2
. Task1_2.sh cleanRedditData.csv

printf "\n"
echo "PART 3"
printf "\n"

	# run script 3
. Task1_3.sh cleanRedditData.csv

printf "\n"
echo "PART 4"
printf "\n"

	# run script 4
. Task1_4.sh cleanRedditData.csv

printf "\n"
echo "PART 5"
printf "\n"
./Task1_5.sh cleanRedditData.csv

printf "\n"
echo "PART 6"
printf "\n"

	# run script 5
. Task1_6.sh cleanRedditData.csv

rm subsetOdData
