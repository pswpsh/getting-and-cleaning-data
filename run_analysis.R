# This R script, called run_analysis.R, does the following:
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation. 
# 3. Uses descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. Creates a second, independent tidy data set with the average
#    of each variable for each activity and each subject.

library(RCurl)
setwd("C:/MOOC/R/coursera/Stat_inference_proj")
#if (file.info('UCI HAR Dataset')$isdir == FALSE) {
#        dataFile <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
#        dir.create('UCI HAR Dataset')
#        download.file(dataFile, 'UCI-HAR-dataset.zip', method='curl')
#        unzip('./UCI-HAR-dataset.zip')
#}

# 1. Merge the training and the test sets to create one data set.
# - "Features" merges data from "X_train.txt" and "X_test.txt"
# - "Activity" merges data from "Y_train.txt" and "Y_test.txt"
# - "Subject" merges data from "subject_train.txt" and subject_test.txt"
# - Levels of "Activity" are defined in "activity_labels.txt"
# - Names of "Features" are defined in "features.txt"

x.train <- read.table('./UCI HAR Dataset/train/X_train.txt')
x.test <- read.table('./UCI HAR Dataset/test/X_test.txt')
x.data <- rbind(x.train, x.test)

y.train <- read.table('./UCI HAR Dataset/train/y_train.txt')
y.test <- read.table('./UCI HAR Dataset/test/y_test.txt')
y.data <- rbind(y.train, y.test)

subject.train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
subject.test <- read.table('./UCI HAR Dataset/test/subject_test.txt')
subject.data <- rbind(subject.train, subject.test)

names(subject.data)<-c("subject")
#labels
names(y.data)<- c("activity")
#features
feature.name.data <- read.table('./UCI HAR Dataset/features.txt')
names(x.data) <- feature.name.data$V2
#merge all data
allData <- cbind(x.data, subject.data, y.data)

# 2. Extract only the measurements on the mean and standard deviation for each measurement. 

extractNames<-cbind(as.character(feature.name.data$V2[grep("-mean\\(\\)|-std\\(\\)", feature.name.data[, 2])]), "subject", "activity" )
extractData <- subset(allData,select=extractNames)

# 3. Use descriptive activity names to name the activities in the data set.

activity.label <- read.table('./UCI HAR Dataset/activity_labels.txt')
#before factorization
head(extractData$activity)
#after factorization
activity.label$V2 <- toupper(as.character(activity.label$V2))
head(extractData$activity<-activity.label[extractData$activity, 2])

# 4. Appropriately labels the data set with descriptive variable names.

names(extractData)<-gsub("^t", "time-", names(extractData))
names(extractData)<-gsub("^f", "frequency-", names(extractData))
names(extractData)<-gsub("Mag", "Magnitude", names(extractData))
names(extractData)<-gsub("Acc", "Accelerometer", names(extractData))
names(extractData)<-gsub("Gyro", "Gyroscope", names(extractData))
names(extractData)

# 5. Creates a second, independent tidy data set with the average
#    of each variable for each activity and each subject.

library(plyr);
tidyData<-aggregate(. ~subject + activity, extractData, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)
library(knitr)
knit2html("codebook.Rmd");