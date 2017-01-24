## Download the datasets into local folder
setwd('/Users\YBetty\Desktop\Yilma_R\UCI HAR Dataset/');

## Read Activity labels and Features data from file
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Read  Train and Test data from file 
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
XTrain <- read.table("UCI HAR Dataset/train/X_train.txt") #imports x_train.txt
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt") #imports y_train.txt

subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt"); #imports subject_test.txt
XTest <- read.table("UCI HAR Dataset/test/X_test.txt"); #imports x_test.txt
yTest <- read.table("UCI HAR Dataset/test/y_test.txt"); #imports y_test.txt

# Assigin column names to the data imported above
colnames(activityLabels) <- c('activityId','activityType')
colnames(subjectTrain) <- "subjectId"
colnames(XTrain) <- features[,2] 
colnames(yTrain) <- "activityId"

colnames(subjectTest) <- "subjectId"
colnames(XTest) <- features[,2]
colnames(yTest)  <- "activityId"

# Create the final training and test set by merging yTrain, subjectTrain, and xTrain
trainingData <- cbind(yTrain, subjectTrain,XTrain)

# Create the final test set by merging the xTest, yTest and subjectTest data
testData <- cbind(yTest,subjectTest,XTest)

#combine training and test data to create the final dataset
finalData <- rbind(trainingData, testData)

# Extract only the data on mean and standard deviation
colNames <- colnames(finalData)

# Create a logicalVector that contains TRUE values for the ID, mean() & stddev() columns and FALSE for others
logicalVector <- (grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | grepl("-std..",colNames) & !grepl("-std()..-",colNames))

# Subset finalData table based on the logicalVector to keep only desired columns
finalData <- finalData[logicalVector==TRUE]

# Use descriptive activity names to name the activities in the data set

# Merge the finalData set with the acitivityLabels table to include descriptive activity names

finalData <- merge(finalData,activityLabels,by='activityId',all.x=TRUE)

# Updating the colNames vector to include the new column names after merge
colNames <- colnames(finalData)

# Create a new table, finalDataNoActivityType without the activityType column
finalDataNoActivityType <- finalData[,names(finalData) != 'activityType']

# Summarizing the finalDataNoActivityType table to include just the mean of each variable for each activity and each subject
tidyData <- aggregate(finalDataNoActivityType[,names(finalDataNoActivityType) != c('activityId','subjectId')],by=list(activityId=finalDataNoActivityType$activityId,subjectId = finalDataNoActivityType$subjectId),mean)

# Merging the tidyData with activityType to include descriptive acitvity names
tidyData <- merge(tidyData,activityLabels,by='activityId',all.x=TRUE)

# Export the tidyData set 
write.table(tidyData, './tidyData.txt',row.names=TRUE,sep='\t');
