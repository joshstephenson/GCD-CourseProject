---
title: "README"
author: "Joshua Stephenson"
date: "7/6/2020"
output: html_document
---

## Overview of operations for `run_analysis.R`
We were asked to write a script to do the following:
1. Merge the training and the test sets to create one data set.
2. Extract only the measurements on the mean and standard deviation for each measurement.
3. Use descriptive activity names to name the activities in the data set
4. Appropriately label the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

- Steps 1-4 are performed by the function `cleanAndMergeDataSets()` which calls on other helper functions outlined below.
- Step 5 is performed by the function `averageDataSetsByActivityAndSubject()` and written to file `UCI-HAR-tidy-data.txt`
If you would like to read this data file back into R, the following snippet will help:
```
> averaged <- read.table("UCI-HAR-tidy-data.txt", header = T)
> ncol(averaged)
[1] 68
> nrow(averaged)
[1] 180
> head(names(averaged))
[1] "Subject"                                          
[2] "ActivityName"                                     
[3] "MeanOfFrequencyMeanBodyAccelerometerJerkMagnitude"
[4] "MeanOfFrequencyMeanBodyAccelerometerJerkX"        
[5] "MeanOfFrequencyMeanBodyAccelerometerJerkY"        
[6] "MeanOfFrequencyMeanBodyAccelerometerJerkZ" 
```

## More general overview
The script `run_analysis.R` retrieves accelerometer and gyroscope values measured across a range of 30 subjects in 6 different activities. The data is stored on the web in a zip file and is organized into sub-folders for test and train data. This data is retrieved, unzipped and then cleaned and process. This document outlines the specifics of that process.

Data is made available by the Machine Learning Repository of the University of California, Irvine. Read more: [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Dataset attribution:
- Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.


### Step 0. Download and unzip data

The first thing the script does is look for the existence of data.zip. If it's not found, it will be downloaded from
`https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip` and unzipped in the current 
working directory.

The internal function that does this is called `downloadDataAndUnzip()` which requires no arguments.

## Steps 1-4
Steps 1-4 are broken down into various steps outlined here:

#### Read and clean feature names from `features.txt`

The `run_analysis.R` script reads the feature names from the `features.txt` file. (They are not hard-coded in the 
script.) Only features that match the regular expression `(mean|std)` are parsed along with their respective numeric keys
which is then used when parsing the `test` and `train` values. These feature names are cleaned and made into normalized `CamelCase`.

After reviewing the lesson on Tidy Data variable names it did not use spaces  in variable names and given the length of these variables,
I thought it made sense not to make them longer by adding spaces between words. Furthermore, I chose to prefix the X,Y,Z coordinates with
a `.` for increased readability. Additionally, there were cases of the word "Body" appearing as "BodyBody" and those
were simplified (to just "Body").

For example:
- `tBodyAcc-mean()-X` becomes `TimeBodyAccelerationMean.X`
- `fBodyAcc-std()-Y` becomes `FrequencyBodyAccelerationStandardDeviation.Y`
- [See Appendix for full list of feature names ](#Full-list-of-feature-names).

The internal function that performs this is called `getCleanedFeatureNames()` and takes one optional argument:
- `uciHarDataset` a character vector that is set to "UCI HAR Dataset" by default (which is the top-level directory in the zip file downloaded above).

#### Load in `test` and `train` data
- The activity data is read from `X_test.txt` and `X_train.txt` and then merged together in one data.frame. Only the columns that match the 
features parse by `getCleanedFeatureNames()` are saved and passed along. Note: this only includes features for mean and standard deviation.
- The subject values in their original numeric form are appended to the data frame with a column name of `Subject`.
- The activity type is read from `y_test.txt` and `y_train.txt` and is cross-referenced with the string value in 
`activity_labels.txt` and stored in the data frame with a column name of `ActivityType`. It is stored as a lower case value with the underscore removed for better readability.

The internal function that performs this is called `cleanAndMergeDataSets()` which takes no arguments. It relies heavily on `getMeanAndStandardDevData()` which takes two optional arguments:
- `dataDir` a character vector value set to "UCI HAR Dataset" by default (which is the top-level directory in the zip file downloaded above).
- `isTest` a boolean value set to false by default. Setting this to true will obtain the data inside the "train" sub-directory.
It is called once with `isTest` set to FALSE (default behavior) and once again with `isTest` set to TRUE and then combined using `rbind()`

## Step 5. Create a new data frame for averages by subject by activity and export to file
Lastly, the script creates a new data frame with 1 row for each subject for each activity type. There are 30 subjects
and 6 activity types.
- The first column is the `Subject` (a numeric integer value between 1 and 30).
- The second column is `ActivityName` (a character vector) 
- These are followed by all the features matched above (79 columns for mean and standard deviation) where the mean of all those values (for each 
subject and activity) has been calculated. These column names are prefixed with `MeanOf`. (e.g. `MeanOfTimeBodyAccelerationMeanX` and `MeanOfTimeBodyAccelerationStandardDeviationX`). I realize in the case of variables that are already means themselves, this might
appear redundant, and well: it is. However it's what was requested and so I figure they may as well be labeled properly.
- This yields a data frame of 68 columns and 180 rows.
- It then writes the data to a file name named `UCI-HAR-tide-data.txt` which can be found in the repository where this script is located.

The internal function that performs this `averageDataSetsByActivityAndSubject()` and requires a data Frame argument. The dataFrame returned from 
`cleanAndMergeDataSets()` is passed in this case.


## Appendix
##### Full list of feature names
For more information on these variables please refer to CodeBook.md
```
 [1] "Subject"      # Subject is a unique identifier          
 [3] "ActivityName" # Activity name is human readable
 [4] "FrequencyMeanBodyAccelerometerJerkMagnitude"             
 [5] "FrequencyMeanBodyAccelerometerJerkX"                     
 [6] "FrequencyMeanBodyAccelerometerJerkY"                     
 [7] "FrequencyMeanBodyAccelerometerJerkZ"                     
 [8] "FrequencyMeanBodyAccelerometerMagnitude"                 
 [9] "FrequencyMeanBodyAccelerometerX"                         
[10] "FrequencyMeanBodyAccelerometerY"                         
[11] "FrequencyMeanBodyAccelerometerZ"                         
[12] "FrequencyMeanBodyGyroscopeJerkMagnitude"                 
[13] "FrequencyMeanBodyGyroscopeMagnitude"                     
[14] "FrequencyMeanBodyGyroscopeX"                             
[15] "FrequencyMeanBodyGyroscopeY"                             
[16] "FrequencyMeanBodyGyroscopeZ"                             
[17] "FrequencyStandardDeviationBodyAccelerometerJerkMagnitude"
[18] "FrequencyStandardDeviationBodyAccelerometerJerkX"        
[19] "FrequencyStandardDeviationBodyAccelerometerJerkY"        
[20] "FrequencyStandardDeviationBodyAccelerometerJerkZ"        
[21] "FrequencyStandardDeviationBodyAccelerometerMagnitude"    
[22] "FrequencyStandardDeviationBodyAccelerometerX"            
[23] "FrequencyStandardDeviationBodyAccelerometerY"            
[24] "FrequencyStandardDeviationBodyAccelerometerZ"            
[25] "FrequencyStandardDeviationBodyGyroscopeJerkMagnitude"    
[26] "FrequencyStandardDeviationBodyGyroscopeMagnitude"        
[27] "FrequencyStandardDeviationBodyGyroscopeX"                
[28] "FrequencyStandardDeviationBodyGyroscopeY"                
[29] "FrequencyStandardDeviationBodyGyroscopeZ"                
[30] "TimeMeanBodyAccelerometerJerkMagnitude"                  
[31] "TimeMeanBodyAccelerometerJerkX"                          
[32] "TimeMeanBodyAccelerometerJerkY"                          
[33] "TimeMeanBodyAccelerometerJerkZ"                          
[34] "TimeMeanBodyAccelerometerMagnitude"                      
[35] "TimeMeanBodyAccelerometerX"                              
[36] "TimeMeanBodyAccelerometerY"                              
[37] "TimeMeanBodyAccelerometerZ"                              
[38] "TimeMeanBodyGyroscopeJerkMagnitude"                      
[39] "TimeMeanBodyGyroscopeJerkX"                              
[40] "TimeMeanBodyGyroscopeJerkY"                              
[41] "TimeMeanBodyGyroscopeJerkZ"                              
[42] "TimeMeanBodyGyroscopeMagnitude"                          
[43] "TimeMeanBodyGyroscopeX"                                  
[44] "TimeMeanBodyGyroscopeY"                                  
[45] "TimeMeanBodyGyroscopeZ"                                  
[46] "TimeMeanGravityAccelerometerMagnitude"                   
[47] "TimeMeanGravityAccelerometerX"                           
[48] "TimeMeanGravityAccelerometerY"                           
[49] "TimeMeanGravityAccelerometerZ"                           
[50] "TimeStandardDeviationBodyAccelerometerJerkMagnitude"     
[51] "TimeStandardDeviationBodyAccelerometerJerkX"             
[52] "TimeStandardDeviationBodyAccelerometerJerkY"             
[53] "TimeStandardDeviationBodyAccelerometerJerkZ"             
[54] "TimeStandardDeviationBodyAccelerometerMagnitude"         
[55] "TimeStandardDeviationBodyAccelerometerX"                 
[56] "TimeStandardDeviationBodyAccelerometerY"                 
[57] "TimeStandardDeviationBodyAccelerometerZ"                 
[58] "TimeStandardDeviationBodyGyroscopeJerkMagnitude"         
[59] "TimeStandardDeviationBodyGyroscopeJerkX"                 
[60] "TimeStandardDeviationBodyGyroscopeJerkY"                 
[61] "TimeStandardDeviationBodyGyroscopeJerkZ"                 
[62] "TimeStandardDeviationBodyGyroscopeMagnitude"             
[63] "TimeStandardDeviationBodyGyroscopeX"                     
[64] "TimeStandardDeviationBodyGyroscopeY"                     
[65] "TimeStandardDeviationBodyGyroscopeZ"                     
[66] "TimeStandardDeviationGravityAccelerometerMagnitude"      
[67] "TimeStandardDeviationGravityAccelerometerX"              
[68] "TimeStandardDeviationGravityAccelerometerY"              
[69] "TimeStandardDeviationGravityAccelerometerZ"
```
