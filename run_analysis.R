##
##     Getting and Cleaning Data
       Sys.Date()
#         Merges the training and the test sets to create one data set.
#         Extracts only the measurements on the mean and standard deviation for each measurement. 
#         Uses descriptive activity names to name the activities in the data set
#         Appropriately labels the data set with descriptive variable names. 
#         with the average of each variable for each activity and each subject.
#
#########################

library(data.table)
library(memisc)
library(knitr)

filePath <- "/Users/Saida/DataScience/Project"

# Getting the proper directory
getwd()
setwd("/Users/Saida/DataScience/Project")
list.files()

features      <- read.table("features.txt")
labelsAct     <- read.table("activity_labels.txt")

featureMeanSTD       <- grep(".*mean.*|.*std.*", features[,2])
featureMeanSTD.names <- features[featureMeanSTD,2]
featureMeanSTD.names <- gsub('-mean', 'Mean', featureMeanSTD.names)
featureMeanSTD.names <- gsub('-std', 'Std', featureMeanSTD.names)
featureMeanSTD.names <- gsub('[-()]', '', featureMeanSTD.names)


## Reading in the files

subjectTrain    <- read.table("subject_train.txt")
xTrain          <- read.table("X_train.txt")
yTrain          <- read.table("Y_train.txt")


subjectTest     <- read.table("subject_test.txt")
xTest           <- read.table("X_test.txt")
yTest           <- read.table("Y_test.txt")


train <- cbind(subjectTrain, yTrain, xTrain)
test  <- cbind(subjectTest, yTest, xTest)

all   <- rbind(train,test)

colnames(all) <- c("subject","activity",featureMeanSTD.names)

# All the junk to not get confused
 #rm(subjectTest,subjectTrain,xTrain,xTest,yTrain,yTest,train,test)

## Creating factors

all$activity   <- factor ( all$activity, levels=labelsAct[,1],labels=labelsAct[,2])

## Creating a narrow dataframe and casting it to wide with all the means

narrowAll    <- melt(all, id=c("subject","activity"))
tidyData     <- dcast(narrowAll, subject + activity ~ variable, mean)
ls(tidyData)
## Giving meaningful names ot the variables

varNames <- grep(".*Acc.*|.*Gyro.*|.*Mag.*|^t|^f|.*X.*|.*Y.*|.*Z.*", names(tidyData))
varNames.names <- names(tidyData)
varNames.names = gsub('Acc', 'Acceleration', varNames.names)
varNames.names = gsub('Gyro', 'Gyroscope', varNames.names)
varNames.names = gsub('Mag', 'Magnitude', varNames.names)
varNames.names = gsub('^t', 'Time', varNames.names)
varNames.names = gsub('^f', 'Frequency', varNames.names)

colnames(tidyData) <- varNames.names

tidyData <- data.frame(tidyData)
str(tidyData)
write.table(tidyData,file="tidyData.txt",row.names=FALSE)

## Make an output 
knit("run_analysis.r","codebook.md")
