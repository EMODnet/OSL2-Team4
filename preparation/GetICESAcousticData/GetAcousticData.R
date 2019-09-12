#rm(list = ls())

source("myFunctions.R")

# Get the list of submissions
submissions <- getAcousticSubmissions()

# get the biotic files for all the submissions
getBioticDataFile(submissionIDs = idsToDownload)

# get the catch data from all the biotic files
myCatch <- getAllCatchData()

saveRDS(myCatch, file = paste(dataDirectory,"AcousticSurveyCatchData.RDS", sep =""))



