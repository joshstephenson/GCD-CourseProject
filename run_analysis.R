# This script does the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Downloads the data file and unzips if it doesn't exist already
downloadData <- function() {
        zipfilePath <- paste("data.zip", sep = "")
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        if (!file.exists(zipfilePath)) {
                download.file(url, zipfilePath)
        }
        unzip(zipfilePath, overwrite = TRUE)
}

## passed dataDir, type of reading (time or frequency) it returns only the mean and standard deviation columns
## with properly named headers for that type
getMeanAndStandardDevData <- function(dataDir, 
                                      type="time", 
                                      isTest=TRUE,
                                      signals = "Inertial Signals") {
        
        x_filename = if(isTest) {"X_test.txt"} else {"X_train.txt"}
        y_filename = if(isTest) {"y_test.txt"} else {"y_train.txt"}
        subject_filename = if(isTest) {"subject_test.txt"} else {"subject_train.txt"}
        subfolder = if(isTest) {"test"} else {"train"}
        
        types <- c("frequency", "time")
        if (!(type %in% types)) {
                stop("type options: time|frequency")
        }
        features <- getFeatureNames(type)
        
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
        write.table(Data.X, file= "output.txt", row.names = FALSE)        
        Data.X
}

# For each type of either `time` or `frequency` open the features.txt file
# and find all feature names that match the type that also only match mean or
# standard deviation features
getFeatureNames <- function(type = "time", uciHarDataset = "UCI HAR Dataset") {
        filename <- paste(uciHarDataset, "/", "features.txt", sep="")
        if (!file.exists(filename)) {
                stop(paste("Cannot find features.txt (", filename, ")", sep=""))
        }
        features <- read.table(filename)
        
        types <- c("frequency", "time")
        if (!(type %in% types)) {
                stop("type options: time|frequency")
        }
        
        ## Find only the features with `mean` or `std` which represent Mean and standard deviation respectively
        selected_indices <- grep("(mean|std)", features[[2]])
        selected <- features[selected_indices,]
        
        ## Clean up the feature names which will become column names
        # leading `t` should become Time
        if (type == "time") {
                # Find the frequency readings and replace `t` with `Time`
                selected_indices <- grep("^t", selected[[2]])
                selected <- selected[selected_indices,]
                selected[[2]] <- gsub("^t", "Time", selected[[2]])
        }else if (type == "frequency") {
                # Find the frequency readings and replace `r` with `Frequency`
                selected_indices <- grep("^f", selected[[2]])
                selected <- selected[selected_indices,]
                selected[[2]] <- gsub("^f", "Frequency", selected[[2]])       
        }
        
        # Acceleration should not be abbreviated
        selected[[2]] <- gsub("Acc", "Acceleration", selected[[2]])
        
        # Standard Deviation should not be abbreviated
        selected[[2]] <- gsub("std", "StandardDeviation", selected[[2]])
        
        # No need for `()` in the column names
        selected[[2]] <- gsub("\\(\\)", "", selected[[2]])
        
        # No need for hyphens
        selected[[2]] <- gsub("-", "", selected[[2]])
        
        # Capatalize Mean
        selected[[2]] <- gsub("mean", "Mean", selected[[2]])
        
        selected
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

downloadData()
getActivityNames()
getMeanAndStandardDevData("UCI HAR Dataset", type="time", isTest=TRUE)