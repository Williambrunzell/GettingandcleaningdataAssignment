# Script to import data from the "Human Activity Recognition Using Smartphones Data Set" 
#
# Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. 
# A Public Domain Dataset for Human Activity Recognition Using Smartphones. 
# 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, 
# ESANN 2013. Bruges, Belgium 24-26 April 2013.

#Instructions:
# Download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Unzip folder to your WD and run script

library(tidyverse)

#Import features and remove id column

features <- read.csv("UCI HAR Dataset/features.txt", header = FALSE, sep=" ")
features <- features[,2]

#Import training data, activity label and subject ID. Merges 3 data sets and renames columns with "features"

data.train.x <- read.table("UCI HAR Dataset/train/X_train.txt")
data.train.y <- read.table("UCI HAR Dataset/train/y_train.txt")
data.train.subject <- read.table("UCI HAR Dataset/train/subject_train.txt")

data.train <- data.frame(data.train.subject, data.train.y, data.train.x)
names(data.train) <- c("subject", "activity", features)

#Import test data, activity label and subject ID. Merges 3 data sets and renames columns with "features"

data.test.x <- read.table("UCI HAR Dataset/test/X_test.txt")
data.test.y <- read.table("UCI HAR Dataset/test/y_test.txt")
data.test.subject <- read.table("UCI HAR Dataset/test/subject_test.txt")

data.test <- data.frame(data.test.subject, data.test.y, data.test.x)
names(data.test) <- c("subject", "activity", features)

#Merge both training and test data - check that observations matches 10299

all.data <- rbind(data.train, data.test)

#Extract only measurements of the mean and standard deviation
columns <- grep("mean|std", features)

measurement.data <- all.data[,c(1,2,columns+2)]

#Import the descriptive names of activities to add to data set
data.activity <- read.table("UCI HAR Dataset/activity_labels.txt")
data.activity <- data.activity[,2]

measurement.data$activity <- data.activity[measurement.data$activity]

#Rename columns from acronym to full word
names(measurement.data) <- gsub("^t", "Time", names(measurement.data))
names(measurement.data) <- gsub("^f", "Frequency", names(measurement.data))
names(measurement.data) <- gsub("Acc", "Accelerometer", names(measurement.data))
names(measurement.data) <- gsub("Gyro", "Gyroscope", names(measurement.data))
names(measurement.data) <- gsub("Mag", "Magnitude", names(measurement.data))

#Create output data set with mean of each variable per subject per activity
tidy.data <- measurement.data %>%
  group_by(subject, activity) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE)

#Exports a new file with the tidy data, ready for analysis
write.table(tidy.data, "tidy.txt", row.names = FALSE)

