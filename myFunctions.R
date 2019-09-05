library(httr)
library(jsonlite)
library(data.table)

submissionAPI <- 'https://acoustic.ices.dk/submissions/getuploadlist'
bioticAPI <- 'https://acoustic.ices.dk/submissions/downloadbioticcsv/'

dataDirectory <- "./data/"

# Get the acoustic survey submissions from ICES
getAcousticSubmissions <- function(){
  
  submissions <- GET(submissionAPI)
  
  submissions_content <- content(submissions,"text")
  
  submissions_json <- fromJSON(submissions_content, flatten = TRUE)
  
  submissions_df <- as.data.frame(submissions_json)
  
  submissions_df
}

# try and download the biotic data - it is supplied as a zip which we need to unzip
getBioticDataFile <- function(submissionIDs){
  
  #idToDownload <- submissionID
  
  for (idToDownload in submissionIDs){
  

  unzipDirectory <- paste(dataDirectory,idToDownload, sep = "")
  fileName <- paste(idToDownload, ".zip", sep = "")
  dest <- paste(dataDirectory, fileName, sep = "")
  myURL <- paste(bioticAPI,idToDownload, sep = "")
  
  download.file(myURL, dest, mode="wb")
  
  unzip(dest, exdir = unzipDirectory)
  
  }
  
}

# Rename the data frame columns to useful values (not written in a very R way...)
renameBioticColumns <- function(myBioticDF){
  
  #myBioticDF <- bCruise
  
  myNames <- myBioticDF[myBioticDF$V2=="Header",]
  namesToCheck <- head(myNames,1)
  validNames<- list()
  i <- 1
  
  for (myValue in namesToCheck){
    #print(myValue)
    if (!is.na(myValue) &  myValue!= ""){
      validNames[[i]]<-myValue
      i <- i + 1
    }
  }
  
  j<- 1
  for (newName in validNames){
    names(myBioticDF)[[j]]<-newName
    j <- j + 1
    
  }
  
  j <- j -1
  myBioticDF[myBioticDF$Header=="Record",1:j]
  
}

# Get the catch data from all the csv files in the data directory
getAllCatchData<-function(){
  
  filesToCheck <- list.files(dataDirectory, recursive = TRUE)
  
  csvFiles <- list()
  k<- 1
  for (aFile in filesToCheck){
    if (grepl(".csv", aFile))
    {
      csvFiles[[k]]<- aFile
      k<- k+1
    }
    
  }
  paste(dataDirectory,csvFiles[[1]],sep="")
  csvFiles<- paste(dataDirectory,csvFiles,sep="")
  
  myCatch <- getCatchDataFromFiles(listOfFiles =csvFiles)
  
  myCatch
}

# Get the catch data from a list of files
getCatchDataFromFiles<-function(listOfFiles){
  
  myOutput <- NULL
  
  for (myFile in listOfFiles){
    myDF <-getCatchData(myFile)
    if (is.null(myOutput)){
      myOutput <- myDF
    } else {
      myOutput<- rbind(myOutput,myDF)
    }
  }
  
  myOutput
  
}

# Read data from a give biotic file and return a data from with the catch data
getCatchData<- function(fileName){
  
  #fileName<-"./data/35/Biotic_RUNT2015BASS.csv"
  
  bioticData <- fread(fileName, fill = TRUE)
  
  bCruise <- bioticData[bioticData$V1=="Cruise",]
  bHaul <- bioticData[bioticData$V1=="Haul",]
  bCatch <- bioticData[bioticData$V1=="Catch",]
  bBiology <- bioticData[bioticData$V1=="Biology",]
  
  bCruise_rename<-renameBioticColumns(myBioticDF=bCruise)
  bHaul_rename<-renameBioticColumns(myBioticDF=bHaul)
  bCatch_rename<-renameBioticColumns(myBioticDF=bCatch)
  bBiology_rename<-renameBioticColumns(myBioticDF=bBiology)
  
  # Catch data incudes length frequency data so the values we're interested in can be repeated
  # We'll remove these duplicates here
  bCatch_unique <- unique(bCatch_rename[,c("Catch","CruiseLocalID","HaulGear","HaulNumber","CatchDataType","CatchSpeciesCode","CatchSpeciesValidity","CatchSpeciesCategory","CatchSpeciesCategoryNumber")])
  
  # Merge the data so we have the number of fish caught with cruise and haul details combined
  preCursor1 <- merge(bCruise_rename,bHaul_rename)
  CatchData <- merge(preCursor1,bCatch_unique,by=c("CruiseLocalID","HaulNumber","HaulGear"))
  
  CatchData
  
}
