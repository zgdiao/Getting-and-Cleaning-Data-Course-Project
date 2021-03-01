#-------------------------------------------------------------------------------
# download and unzip input file

## download the zip file for the project
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./projectData_getCleanData.zip")

## unzip the file
unzip("./projectData_getCleanData.zip")


#-------------------------------------------------------------------------------
# Task 1: Merges the training and the test sets to create one data set.

## load train and test data into R
input_dir <- "./UCI HAR Dataset/"
full_path <- function(x){paste(input_dir, x, sep = "")}

train_x <- read.table(full_path("train/X_train.txt"))
train_y <- read.table(full_path("train/y_train.txt"))
train_subject <- read.table(full_path("train/subject_train.txt"))
test_x <- read.table(full_path("test/X_test.txt"))
test_y <- read.table(full_path("test/y_test.txt"))
test_subject <- read.table(full_path("test/subject_test.txt"))

## merge train and test data sets
df_train <- cbind(train_subject, train_y, train_x)
df_test <- cbind(test_subject, test_y, test_x)
df_union <- rbind(df_train, df_test)


#-------------------------------------------------------------------------------
# Task 2: Extracts only the measurements on the mean and standard deviation for each measurement. 

## load feature names to R
features_path <- full_path("features.txt")
df_features <- read.table(features_path)

## extract the measurements on the mean and standard deviation
df_mean_std_index <- grep("(mean|std)\\(", df_features[[2]])
df_union <- df_union[, c(1, 2, df_mean_std_index + 2)]
names(df_union) <- c("subject", "activity", df_features[[2]][df_mean_std_index])


#-------------------------------------------------------------------------------
# Task 3: Uses descriptive activity names to name the activities in the data set

## load activities to R
activity_path <- full_path("activity_labels.txt")
df_activity_labels <- read.table(activity_labels_path)

## replace numbers 1-6 with activity names
df_union$activity <- factor(df_union$activity, levels = df_activity_labels[,1], labels = df_activity_labels[,2])


#-------------------------------------------------------------------------------
# Task 4: Appropriately labels the data set with descriptive variable names. 
names(df_union) <- gsub("^t", "time", names(df_union))
names(df_union) <- gsub("^f", "frequence", names(df_union))
names(df_union) <- gsub("-mean\\(\\)", "Mean", names(df_union))
names(df_union) <- gsub("-std\\(\\)", "Std", names(df_union))


#-------------------------------------------------------------------------------
# Task 5: From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject. 

## use dplyr library to group data and aggregate each variable
## add a prefix "mean_" to each variable name
library(dplyr)
df <- df_union %>%
        group_by(subject, activity) %>%
        summarise(across(everything(), list(mean), .names = "mean_{.col}"))


## output the result
write.table(df, "tidy_data.txt", row.names = FALSE)
