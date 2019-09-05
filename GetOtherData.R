source("myFunctions.R")


speciesToCheck <- "Gadus morhua"


myId <- getAphiaID(sciName = speciesToCheck)

myVernculars <- getVernaculars(myId)
myVerncularsEng <- myVernculars[myVernculars$language_code=="eng",c("vernacular")]

myRecipes<-getRecipeURL(myVerncularsEng)
