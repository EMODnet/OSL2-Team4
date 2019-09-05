library(worms)
library(urltools)
library(httr)
library(jsonlite)
library(SPARQL)



# https://www.bbc.co.uk/food/search?q=cod
recipeBBCURL <- "https://www.bbc.co.uk/food/search?q="
wormsBaseURL <- "http://www.marinespecies.org/rest/"

myEndpoint <- "https://dbpedia.org/sparql"

myPrefix <- "PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
PREFIX dbo: <http://dbpedia.org/ontology/>
PREFIX dbp: <http://dbpedia.org/property/>
PREFIX dbr: <http://dbpedia.org/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>"


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

# run the supplied sparql with the prefix and return the results
runSparql<-function(mySpaqrl){
  myQuery <- paste(myPrefix,mySpaqrl,sep = " ")
  qd <- SPARQL(myEndpoint,myQuery)
  df <- qd$results
  return (df)
}

# For a given untyped, lower-case scientific name try and retrive species infromation from dbpedia
getSpeciesInfoFromDBPedia<-function(sciName){
  
  
  mySparql1 <- 'SELECT ?species (str(?name) as ?Name) ?image (str(?abstract) as ?Abstract) ?page ?origPage ?map (str(?name) as ?untypedName) 
WHERE  {  
  ?species dbp:binomial ?name .
  ?species dbo:thumbnail ?image  .  
  ?species dbo:abstract ?abstract . 
OPTIONAL { ?species <http://xmlns.com/foaf/0.1/isPrimaryTopicOf> ?page . }
OPTIONAL { ?species <http://www.w3.org/ns/prov#wasDerivedFrom> ?origPage . }
OPTIONAL { ?species dbp:rangeMap ?map . }   
FILTER (lang(?abstract) = "en")
FILTER (str(?name) = "'
  
  mySparql2 <- '")} LIMIT 1'

  
  #sciName <- "Gadus morhua"
  
  mySparqlAll <- paste(mySparql1,sciName,mySparql2, sep = "")
  #print(mySparqlAll)
  
  r <- runSparql(mySparqlAll)
  
  }

# Get the end part of IRIs for display
trimIRI<- function(IRI_List){
  
  matches <- regexpr("\\/[^\\/]*$", IRI_List)
  trimmedList <- substring(IRI_List,matches+1,nchar(IRI_List)-1)
}

removeBrackets<-function(myString){
  
  myString <- substring(myString,2)
  myString <- substring(myString,1,nchar(myString)-1)
  myString
  
}

# Get the extra infromation for mutiple species
getSpeciesInfo<- function(listOfSpecies){
  
  myOutput <- NULL
  for(aSpecies in listOfSpecies){
    myResult <- getSpeciesInformation(speciesToCheck = aSpecies)
    if (is.null(myOutput)){
      myOutput <- myResult
    } else {
      myOutput <- rbind(myOutput,myResult)
    }
  }
  
  myOutput
}

# Bring together the data
getSpeciesInformation <- function(speciesToCheck){
  
  
  myId <- getAphiaID(sciName = speciesToCheck)
  
  myVernculars <- getVernaculars(myId)
  myVerncularsEng <- myVernculars[myVernculars$language_code=="eng",c("vernacular")]
  
  myRecipes<-getRecipeURL(myVerncularsEng)
  
  myDBPediaInfo <- getSpeciesInfoFromDBPedia(sciName = speciesToCheck)
  
  myOutput <- data.frame(SciName = speciesToCheck, AphiaID = myId, CommonName = head(myVerncularsEng,1), Image = removeBrackets(myDBPediaInfo$image), Abstract = myDBPediaInfo$Abstract, WikipediaPage = removeBrackets(myDBPediaInfo$origPage), RecipeURL = head(myRecipes,1))
  
  myOutput
  
  
}




