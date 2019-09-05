source("myFunctions.R")

# Define a list of species we'll get the extra data for
speciesToCheck <- c("Capros aper","Clupea harengus","Dipturus batis","Gadus morhua","Glyptocephalus cynoglossus","Lepidorhombus whiffiagonis","Lophius piscatorius","Melanogrammus aeglefinus","Merlangius merlangus","Merluccius merluccius","Micromesistius poutassou","Microstomus kitt","Molva molva","Pleuronectes platessa","Pollachius pollachius","Pollachius virens","Raja clavata","Scophthalmus rhombus","Solea solea","Sprattus sprattus","Trachurus trachurus","Zeus faber")
  
ExtraFishData <- getSpeciesInfo(speciesToCheck)

saveRDS(ExtraFishData,"ExtraFishData.RDS")


