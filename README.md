---
title: "README"
author: "Joshua Stephenson"
date: "7/6/2020"
output: html_document
---

## Overview of operations for `run_analysis.R`
The script `run_analysis.R` retrieves acceleromater and gyroscope values measured across a range of 30 subjects in 6 different activities. The data is stored on the web in a zip file and is organized into subfolders based on whether it is test or train data. This data is retrieved, unzipped and then cleaned and process. This document outlines the specifics of that process.

Data is made available by the Machine Learning Repository of the University of California, Irvine. Read more: [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Individuals responsible for this project:
- Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.


### Download and unzip data

The first thing the script does is look for the existence of data.zip. If it's not found, it will be downloaded from
`https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip` and unzipped in the current 
working directory.

The internal function that does this is called `downloadDataAndUnzip()` which requires no arguments.

### Read and clean feature names from `features.txt`

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

### Load in `test` and `train` data
• The activity data is read from `X_test.txt` and `X_train.txt` and then merged together in one data.frame. Only the columns that match the 
features parse by `getCleanedFeatureNames()` are saved and passed along. Note: this only includes features for mean and standard deviation.
• The subject values in their original numeric form are appended to the data frame with a column name of `Subject`.
• The activity type is read from `y_test.txt` and `y_train.txt` and is cross-referenced with the string value in 
`activity_labels.txt` and stored in the data frame with a column name of `ActivityType`. It is stored as a lower case value with the underscore removed for better readability.

The internal function that performs this is called `mergeDataSets()` which takes no arguments. It relies heavily on `getMeanAndStandardDevData()` which takes two optional arguments:
- `dataDir` a character vector value set to "UCI HAR Dataset" by default (which is the top-level directory in the zip file downloaded above).
- `isTest` a boolean value set to false by default. Setting this to true will obtain the data inside the "train" sub-directory.
It is called once with `isTest` set to FALSE (default behavior) and once again with `isTest` set to TRUE and then combined using `rbind()`

### New Data Frame for Averages by Subject and Activity
Lastly, the script creates a new data frame with 1 row for each subject for each activity type. There are 30 subjects
and 6 activity types.
- The first column is the `Subject` (a numeric value).
- The second column is `ActivityName` (a character vector) 
- These are followed by all the features matched above (79 columns for mean and standard deviation) where the mean of all those values (for each 
subject and activity) has been calculated. These column names are prefixed with `Mean.`. (e.g. `Mean.TimeBodyAccelerationMean.X` and `Mean.TimeBodyAccelerationStandardDeviation.X`).
- This yields a data frame of 81 columns and 180 rows.
- It then writes the data to a file name

The internal function that performs this `averageDataSetsByActivityAndSubject()` and requires a data Frame argument. The dataFrame returned from 
`mergeDataSets()` is passed in this case.

If you would like to read this data file back into R, the following snippet will help:
```
> averaged <- read.table("UCI-HAR-MeanBySubjectAndActivity.txt", header=T)
> ncol(averaged)
[1] 81
> nrow(averaged)
[1] 180
> head(names(averaged))
[1] "Subject"                                     
[2] "ActivityName"                                
[3] "Mean.TimeBodyAccelerationMean.X"             
[4] "Mean.TimeBodyAccelerationMean.Y"             
[5] "Mean.TimeBodyAccelerationMean.Z"             
[6] "Mean.TimeBodyAccelerationStandardDeviation.X"
```

## Appendix
##### Full list of feature names
```
data <- mergeDataSets()
 [1] "TimeBodyAccelerationMean-X"                       
 [2] "TimeBodyAccelerationMean-Y"                       
 [3] "TimeBodyAccelerationMean-Z"                       
 [4] "TimeBodyAccelerationStandardDeviation-X"          
 [5] "TimeBodyAccelerationStandardDeviation-Y"          
 [6] "TimeBodyAccelerationStandardDeviation-Z"          
 [7] "TimeGravityAccelerationMean-X"                    
 [8] "TimeGravityAccelerationMean-Y"                    
 [9] "TimeGravityAccelerationMean-Z"                    
[10] "TimeGravityAccelerationStandardDeviation-X"       
[11] "TimeGravityAccelerationStandardDeviation-Y"       
[12] "TimeGravityAccelerationStandardDeviation-Z"       
[13] "TimeBodyAccelerationJerkMean-X"                   
[14] "TimeBodyAccelerationJerkMean-Y"                   
[15] "TimeBodyAccelerationJerkMean-Z"                   
[16] "TimeBodyAccelerationJerkStandardDeviation-X"      
[17] "TimeBodyAccelerationJerkStandardDeviation-Y"      
[18] "TimeBodyAccelerationJerkStandardDeviation-Z"      
[19] "TimeBodyGyroMean-X"                               
[20] "TimeBodyGyroMean-Y"                               
[21] "TimeBodyGyroMean-Z"                               
[22] "TimeBodyGyroStandardDeviation-X"                  
[23] "TimeBodyGyroStandardDeviation-Y"                  
[24] "TimeBodyGyroStandardDeviation-Z"                  
[25] "TimeBodyGyroJerkMean-X"                           
[26] "TimeBodyGyroJerkMean-Y"                           
[27] "TimeBodyGyroJerkMean-Z"                           
[28] "TimeBodyGyroJerkStandardDeviation-X"              
[29] "TimeBodyGyroJerkStandardDeviation-Y"              
[30] "TimeBodyGyroJerkStandardDeviation-Z"              
[31] "TimeBodyAccelerationMagMean"                      
[32] "TimeBodyAccelerationMagStandardDeviation"         
[33] "TimeGravityAccelerationMagMean"                   
[34] "TimeGravityAccelerationMagStandardDeviation"      
[35] "TimeBodyAccelerationJerkMagMean"                  
[36] "TimeBodyAccelerationJerkMagStandardDeviation"     
[37] "TimeBodyGyroMagMean"                              
[38] "TimeBodyGyroMagStandardDeviation"                 
[39] "TimeBodyGyroJerkMagMean"                          
[40] "TimeBodyGyroJerkMagStandardDeviation"             
[41] "FrequencyBodyAccelerationMean-X"                  
[42] "FrequencyBodyAccelerationMean-Y"                  
[43] "FrequencyBodyAccelerationMean-Z"                  
[44] "FrequencyBodyAccelerationStandardDeviation-X"     
[45] "FrequencyBodyAccelerationStandardDeviation-Y"     
[46] "FrequencyBodyAccelerationStandardDeviation-Z"     
[47] "FrequencyBodyAccelerationMeanFreq-X"              
[48] "FrequencyBodyAccelerationMeanFreq-Y"              
[49] "FrequencyBodyAccelerationMeanFreq-Z"              
[50] "FrequencyBodyAccelerationJerkMean-X"              
[51] "FrequencyBodyAccelerationJerkMean-Y"              
[52] "FrequencyBodyAccelerationJerkMean-Z"              
[53] "FrequencyBodyAccelerationJerkStandardDeviation-X" 
[54] "FrequencyBodyAccelerationJerkStandardDeviation-Y" 
[55] "FrequencyBodyAccelerationJerkStandardDeviation-Z" 
[56] "FrequencyBodyAccelerationJerkMeanFreq-X"          
[57] "FrequencyBodyAccelerationJerkMeanFreq-Y"          
[58] "FrequencyBodyAccelerationJerkMeanFreq-Z"          
[59] "FrequencyBodyGyroMean-X"                          
[60] "FrequencyBodyGyroMean-Y"                          
[61] "FrequencyBodyGyroMean-Z"                          
[62] "FrequencyBodyGyroStandardDeviation-X"             
[63] "FrequencyBodyGyroStandardDeviation-Y"             
[64] "FrequencyBodyGyroStandardDeviation-Z"             
[65] "FrequencyBodyGyroMeanFreq-X"                      
[66] "FrequencyBodyGyroMeanFreq-Y"                      
[67] "FrequencyBodyGyroMeanFreq-Z"                      
[68] "FrequencyBodyAccelerationMagMean"                 
[69] "FrequencyBodyAccelerationMagStandardDeviation"    
[70] "FrequencyBodyAccelerationMagMeanFreq"             
[71] "FrequencyBodyAccelerationJerkMagMean"             
[72] "FrequencyBodyAccelerationJerkMagStandardDeviation"
[73] "FrequencyBodyAccelerationJerkMagMeanFreq"         
[74] "FrequencyBodyGyroMagMean"                         
[75] "FrequencyBodyGyroMagStandardDeviation"            
[76] "FrequencyBodyGyroMagMeanFreq"                     
[77] "FrequencyBodyGyroJerkMagMean"                     
[78] "FrequencyBodyGyroJerkMagStandardDeviation"        
[79] "FrequencyBodyGyroJerkMagMeanFreq"                 
[80] "Subject"                                          
[81] "ActivityName"                             
```

###
