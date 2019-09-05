library(worms)
library(urltools)
library(httr)
library(jsonlite)



# https://www.bbc.co.uk/food/search?q=cod
recipeBBCURL <- "https://www.bbc.co.uk/food/search?q="
wormsBaseURL <- "http://www.marinespecies.org/rest/"




# Try and get the aphia id for a scientific name
getAphiaID <- function(sciName){
  
  wormsAphiaIDURL <- paste(wormsBaseURL, "AphiaRecordsByName/", sciName, "?like=false&marine_only=true&offset=1", sep = "" )
  
  wormsAphiaIDURL <- URLencode(wormsAphiaIDURL)
  
  sciName <- GET(wormsAphiaIDURL)
  
  sciName_content <- content(sciName,"text")
  
  sciName_json <- fromJSON(sciName_content, flatten = TRUE)
  
  myAphiaID <- sciName_json$AphiaID
  
  myAphiaID
  
}


getVernaculars<-function(aphiaID){
  
  wormsVernacularURL <- paste(wormsBaseURL, "AphiaVernacularsByAphiaID/", aphiaID, sep = "" )
  
  wormsVernacularURL <- URLencode(wormsVernacularURL)
  
  vernaculars <- GET(wormsVernacularURL)
  
  vernaculars_content <- content(vernaculars,"text")
  
  vernaculars_json <- fromJSON(vernaculars_content, flatten = TRUE)
  
  vernaculars_json
  
  #myAphiaID <- sciName_json$AphiaID
  
}

# Get a URL for recipes with that ingredient
getRecipeURL<-function(commonName){
  
  recipeLink <- paste(recipeBBCURL, commonName, sep = "")
  recipeLink <- URLencode(recipeLink)
}

