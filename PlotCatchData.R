
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)

dataDirectory <- "./data/"

SurveyCatchData <- readRDS(paste(dataDirectory,"AcousticSurveyCatchData.RDS", sep =""))

DataToPlot <- SurveyCatchData
  
DataToPlot$HaulStartLongitude <- as.numeric(SurveyCatchData$HaulStartLongitude)
DataToPlot$HaulStartLatitude <- as.numeric(SurveyCatchData$HaulStartLatitude)
  
world <- ne_countries(scale = "medium", returnclass = "sf")
  
minLon <- min(DataToPlot$HaulStartLongitude, na.rm = T)
maxLon <- max(DataToPlot$HaulStartLongitude, na.rm = T)
  
minLat <- min(DataToPlot$HaulStartLatitude, na.rm = T)
maxLat <- max(DataToPlot$HaulStartLatitude, na.rm = T)
  

p <- ggplot(data = world) +
    geom_sf() +
    geom_point(data = DataToPlot[,], aes_string(x = "HaulStartLongitude", y = "HaulStartLatitude")) +
    coord_sf(xlim = c(minLon,maxLon ), ylim = c(minLat, maxLat), expand = TRUE)

print(p)



