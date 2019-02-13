library(raster)
library(rgeos)
library(sp)
library(rgdal)
library(rmapshaper)
library(adehabitatMA)
library(maptools) 
library(plyr)
library(dplyr)
library (tmap)
library(tmaptools)





#subir data coordenadas - conglomerado - parcela
setwd("/storepelican/bgobbi/R/INPUTS/tables")
CRS.new <- CRS("+proj=utm +zone=20 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
coordenadas.name<-"coordenadas_todos"
setwd("/storepelican/bgobbi/R/INPUTS/table")
coordenadas.df<-read.table(paste(coordenadas.name,".csv",sep=""),sep=";",header = TRUE,stringsAsFactors = FALSE)
coordenadas.sp<-SpatialPoints(coordenadas.df[,c(4,3)])
coordenadas.spdf<-SpatialPointsDataFrame(coordenadas.sp,coordenadas.df)
coordenadas.spdf@proj4string<-CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
coordspro<-spTransform(coordenadas.spdf, CRS.new)
plot(coordspro)
files1<-list.files("/storepelican/bgobbi/R/INPUTS/projected/dem", pattern = ".tif")
files <- list()
setwd("/storepelican/bgobbi/R/INPUTS/projected/dem")
for (i in 1:length(files1)){ 
  
  # files2<- list.files("/storepelican/bgobbi/R/Data_processing", pattern = ".tif")
  print(files1 [i]) 
  files[[i]]<-raster(files1[i])
  
  # files[[1]] <-raster( "180912_10.tif")
  # files[[2]] <- raster("180912_13.tif")
  # files[[3]] <-raster("180913_15.tif")
  
}
s_red<-lapply(files, function(x) {y=extract(x,coordspro); return(y)})
DT <-as.data.frame(s_red)
c<-files1
colnames(DT)<-c(c)
dim(DT)

DT2<-DT /DT

DT2$plot=coordenadas.df$PLOT
DT2$parcela=coordenadas.df$PARCEL
DT2$X = coordenadas.df$X
DT2$Y=  coordenadas.df$Y
library(reshape)


mdata <- melt(DT2, id=c("plot","parcela","X", "Y"), na.rm=TRUE)

