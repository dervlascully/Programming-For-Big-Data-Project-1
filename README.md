Grade: 100% (A+)

# Programming-For-Big-Data-Project-1
Project for the module COMP30770 Programming for Big Data


Project: CLI (Bash) & Data Management for Big Data

Broject Brief: COMP30770_2021_Project_11.pdf


The dataset used for this project is reddit_20201.csv.
I downloaded it with: wget csserver.ucd.ie/~thomas/reddit_2021.csv

The folder Scripts & Data contains all of my Bash Scripts and data. The scripts are named according to the Task that they do. Task 1 of the project has 6 parts, so the corresponding scripts are named Task1_1.sh, Task1_2.sh, Task1_3.sh, Task1_4.sh, Task1_5.sh, and Task1_6.sh and Task1_6_stem.sh.

Task 1:

runTask1_Scripts.sh takes in the reddit_2021.csv file as command line argument, runs all of the scripts for Task 1, and writes the resulting data to cleanRedditData.csv.
It can be ran with ./runTask1_Scripts.sh reddit_2021.csv

Task1_1.sh takes in the reddit_2021.csv dataset as command line argument. It removes the columns 1, 2, 3 and 34 and writes the resulting data to the file cleanRedditData.csv.

cleanRedditData.csv is the file to be used as command line argument to all other scripts.

Task1_2.sh takes in the cleanRedditData.csv file as command line argument and removes all columns that contain all empty values. It writes the resulting data back to  cleanRedditData.csv.

Task1_3.sh takes in the cleanRedditData.csv file as command line argument and removes all columns that contain the same value for all rows. It writes the resulting data back to  cleanRedditData.csv.

Task1_4.sh  takes in the cleanRedditData.csv file as command line argument and converts the values in the columns created_utc and retrieved_on from seconds since epoch to month, and writes the resulting data back to  cleanRedditData.csv.

Task1_5.sh takes in the cleanRedditData.csv file as command line argument and counts the number of posts made in each subreddit each month and prints the results to the screen.

Task1_6.sh takes in the cleanRedditData.csv file as command line argument and converts all of the values in the title column to lower case, removes punctuation and removes stop words, and writes the resulting data back to  cleanRedditData.csv.

Task1_6_stem.sh takes in the cleanRedditData.csv file as command line argument uses a stemming technique to stem the words in the title column,and writes the resulting data back to  cleanRedditData.csv.

Task 2:

Task2_PopulateSQLTable.sh takes in the cleanRedditData.csv file cleanRedditData.csv as command line argument and populates tables in the MySQL database RedditDB.

Task2_PopulateMongoDB.sh takes in the cleanRedditData.csv file cleanRedditData.csv as command line argument and creates a database and collection and populates the collection in MongoDB.

Stop Word & Stemming Files:

stopwords.txt is the file containing stop words which is used in Task1_6.sh
I downloaded it using wget http://astellar.com/downloads/stopwords.txt

diffs.txt is the file containing words and their stemming replacements which is used in  Task1_6_stem.sh
I downloaded it using wget http://snowball.tartarus.org/algorithms/english/diffs.txt.
