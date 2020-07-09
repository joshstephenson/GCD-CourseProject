# This script does the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Downloads the data file and unzips if it doesn't exist already
downloadDataAndUnzip <- function() {
        zipfilePath <- paste("data.zip", sep = "")
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        if (!file.exists(zipfilePath)) {
                download.file(url, zipfilePath)
        }
        unzip(zipfilePath, overwrite = TRUE)
}

## passed dataDir, type of reading (time or frequency) it returns only the mean and standard deviation columns
## with properly named headers for that type
getMeanAndStandardDevData <- function(dataDir = "UCI HAR Dataset", isTest=TRUE) {
        
        x_filename = if(isTest) {"X_test.txt"} else {"X_train.txt"}
        y_filename = if(isTest) {"y_test.txt"} else {"y_train.txt"}
        subject_filename = if(isTest) {"subject_test.txt"} else {"subject_train.txt"}
        subfolder = if(isTest) {"test"} else {"train"}
        
        features <- getCleanedFeatureNames()
        
        Path.X <- paste(dataDir, "/", subfolder, "/", x_filename, sep = "")
        Data.X <- read.table(Path.X, header = F)
        Data.X <- Data.X[features[[1]]]
        names(Data.X) <- features[[2]]
        
        # Add the subject to the data table as a new column `Subject`
        Path.subject <- paste(dataDir, "/", subfolder, "/", subject_filename, sep = "")
        Data.subject <- read.table(Path.subject, header = F)
        Data.X["Subject"] = Data.subject[[1]]
        Data.X

        ## Add the activity type from the y_test or y_train file as a new column `ActivityType`
        # Making sure to replace the numeric value with the string value from the `activity_labels.txt` file
        activities <- getActivityNames()
        Path.Y <- paste(dataDir, "/", subfolder, "/", y_filename, sep = "")
        Data.Y <- read.table(Path.Y, header = F)
        names(Data.Y) <- c("ID")
        
        Data.merged <- merge(Data.Y, activities, by="ID",all=TRUE)
        Data.merged
        Data.X["ActivityName"] = Data.merged["Name"]
        # Data.X["ActivityID"] = Data.merged["ID"]
        Data.X
}

cleanFeatures <- function(features, selected_indices) {
        selected <- features[selected_indices,]
        
        ## Filter out meanFreq because it's redundant with step 5 of this assignment
        meanFreq <- grep("meanFreq", selected[[2]], invert = T)
        selected <- selected[meanFreq,]
        
        # Remove "Freq" from the end because it's redundant of the `f`
        selected[[2]] <- gsub("Freq\\(\\)", "Frequency", selected[[2]])
        
        # Accelerometer is better than Acc
        selected[[2]] <- gsub("Acc", "Accelerometer", selected[[2]])
        
        # Accelerometer is better than Acc
        selected[[2]] <- gsub("Gyro", "Gyroscope", selected[[2]])
        
        # Magnitude is better than Mag
        selected[[2]] <- gsub("Mag", "Magnitude", selected[[2]])
        
        # No need for `()` in the column names
        selected[[2]] <- gsub("\\(\\)", "", selected[[2]])
        
        # No need for hyphens
        selected[[2]] <- gsub("-", "", selected[[2]])
        
        # Replace BodyBody with Body as it's likely a typo
        # https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project/discussions/threads/yD2gtalxEeelRgqEwi0dZA
        selected[[2]] <- gsub("BodyBody", "Body", selected[[2]])
        
        # Put a . before the last X,Y or Z for readability
        # selected[[2]] <- gsub("X$", ".X", selected[[2]])
        # selected[[2]] <- gsub("Y$", ".Y", selected[[2]])
        # selected[[2]] <- gsub("Z$", ".Z", selected[[2]])
        
        ## For frequency columns, spell out Frequency and Standard Deviation or Mean and move to the front
        ## because it's the most important part
        count = 1
        for (column in selected[[2]]) {
                if (length(grep("mean", column)) > 0) {
                        if (length(grep("^f", column)) > 0) {
                                column <- gsub("^f", "", column)
                                selected[[count,2]] <- paste("FrequencyMean", gsub("mean", "", column), sep = "")                
                        }else { # Time
                                column <- gsub("^t", "", column)
                                selected[[count,2]] <- paste("TimeMean", gsub("mean", "", column), sep = "")
                        }

                }
                # Capitalize Standard Deviation without abbreviating and move to the front
                if (length(grep("std", column)) > 0) {
                        if (length(grep("^f", column)) > 0) {
                                column <- gsub("^f", "", column)
                                selected[[count,2]] <- paste("FrequencyStandardDeviation", gsub("std", "", column), sep = "")
                        }else{
                                column <- gsub("^t", "", column)
                                selected[[count,2]] <- paste("TimeStandardDeviation", gsub("std", "", column), sep = "")
                        }
                }
                count = count + 1
        }
        selected
}

# For each type of either `time` or `frequency` open the features.txt file
# and find all feature names that match the type that also only match mean or
# standard deviation features
getCleanedFeatureNames <- function(uciHarDataset = "UCI HAR Dataset") {
        library(dplyr)
        filename <- paste(uciHarDataset, "/", "features.txt", sep="")
        if (!file.exists(filename)) {
                stop(paste("Cannot find features.txt (", filename, ")", sep=""))
        }
        features <- read.table(filename)
        
        ## Find only the features with `mean` or `std` which represent Mean and standard deviation respectively
        # We want them sorted so we'll have the Mean columns first and then the Standard Deviation
        meanColumns <- cleanFeatures(features, grep("mean", features[[2]]))
        stdDevColumns <- cleanFeatures(features, grep("std", features[[2]]))
        columns <- arrange(rbind(meanColumns, stdDevColumns), V2)
        names(columns) <- c("ID", "FEATURE NAME")
        columns
}

# Read the activity labels and their corresponding value from activity_labels file
getActivityNames <- function(uciHarDataset = "UCI HAR Dataset") {
        filename <- paste(uciHarDataset, "/", "activity_labels.txt", sep="")
        if (!file.exists(filename)) {
                stop(paste("Cannot find activity_labels.txt (", filename, ")", sep=""))
        }
        activities <- read.table(filename)
        activities[[2]] <- tolower(activities[[2]])
        activities[[2]] <- gsub("_", " ", activities[[2]])
        names(activities) <- c("ID", "Name")
        activities
}

averageDataSetsByActivityAndSubject <- function(dataFrame) {
        newDataFrame <- data.frame(Subject = numeric(0), ActivityName = character(0))
        subjects <- unique(dataFrame["Subject"])
        subjects <- sort(subjects$Subject)
        activities <- unique(dataFrame["ActivityName"])[[1]]
        features <- getCleanedFeatureNames()[[2]]
        
        for(id in subjects) {
                for(name in activities) {
                        filtered <- filter(dataFrame, Subject == id & ActivityName == name)# dataFrame[dataFrame["Subject"] == id & dataFrame["ActivityName"] == name,]
                        new <- data.frame(Subject = id, ActivityName = name)
                        for (feature in features) {
                                count <- length(filtered[,feature])
                                newColumn <- paste("MeanOf", feature, sep = "")
                                selected <- select(filtered, feature)
                                if (nrow(selected) > 0) {
                                        new[newColumn] <- mean(filtered[,feature])
                                }else{
                                        new[newColumn] <- NA
                                }
                                # print(new[newColumn])
                        }
                        # stop()
                        newDataFrame <- rbind(newDataFrame, new)
                }
        }
        newDataFrame
}

# Loads the appropriate data (mean & std with appending activity type and subject value) for each of test and 
# train is loaded and then combined using `rbind`
mergeDataSets <- function() {
        Data.test <- getMeanAndStandardDevData(isTest = TRUE)
        Data.train <- getMeanAndStandardDevData(isTest = FALSE)
        rbind(Data.test, Data.train)
}

# writes provided data frame to file with `write.table`
exportMeanDataBySubjectAndActivity <- function(dataFrame, filename = "UCI-HAR-tidy-data.txt") {
        write.table(dataFrame, file = filename, row.names = FALSE)        
}

# Step 1. Download the data and unzip
downloadDataAndUnzip()

# Step 2. Merge data for `test` and `train`
dataFrame <- mergeDataSets()

# Step 3 (Step 5 from instructions)
averaged <- averageDataSetsByActivityAndSubject(dataFrame)
exportMeanDataBySubjectAndActivity(averaged)

