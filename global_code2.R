library(rgdal)
library(raster)
library(sp)
library(rgeos)
library(TRAMPR)
library(rmapshaper)
setwd

CRS.new <- CRS("+proj=utm +zone=20 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
coord<-mdata

coordenada.sp<-SpatialPoints(coord[,c(3,4)])
coordenada.spdf<-SpatialPointsDataFrame(coordenada.sp,coord)
coordenada.spdf@proj4string<-CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
coordspros<-spTransform(coordenada.spdf, CRS.new)

data<-as.data.frame(coordspros@data)

results<-data.frame() 


 for (i in 1:nrow(coordspros@data)){
  
  print(i)
 name<-data[i ,"variable"] 
 name<-(as.character(name))
  print(name)
  
  raster_filepath<-paste0("/storepelican/bgobbi/R/INPUTS/projected/dem/" , name)
  r<-raster(raster_filepath)
  
 
  split<-unlist(strsplit(name, "[.]"))
  ptcloud.df<-read.table(paste0("/storepelican/bgobbi/R/INPUTS/projected/pts/",split[1], ".txt"))
  ptcloud.sp<-SpatialPoints(ptcloud.df[,c(1,2)])
  ptcloud.spdf<-SpatialPointsDataFrame(ptcloud.sp,ptcloud.df)
  proj4string(ptcloud.spdf) <- CRS("+proj=utm +zone=20 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
  
  #crop point cloud
  
  pt.buffer<-coordspros[i,]
  poly.buffer<-gBuffer(pt.buffer,width = 17.84)
  #crop raster
  raster.crop<-crop(r,poly.buffer)
  raster.mask<-mask(raster.crop,poly.buffer)
  
  
  ############################CORRECTING dem#############################
  
  #USING FIRST PERCENTILE
  
  first<-quantile(raster.mask, c(.02)) 
  CHM<-raster.mask-first
  
  ############################END CORRECTING DEM ########################
  
  
  #crop nuage de pts
  ptcloud.crop<-ptcloud.spdf[poly.buffer,]
  pt_CHM<-ptcloud.crop
  pt_CHM@data$V3<-ptcloud.crop@data$V3-first
  
  buffer<-coordspros[i,"parcela"]
  buffer<-buffer$parcela
  
  work.dir<-setwd("/storepelican/bgobbi/R/drones/dante/data_chaco")
  
  writeRaster(CHM,paste0(name, buffer), format="GTiff", overwrite=TRUE)
  writeOGR(pt_CHM,work.dir,paste0(name, buffer),driver="ESRI Shapefile",overwrite=TRUE)
  
  
 
 }
