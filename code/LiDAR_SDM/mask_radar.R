library(gdalUtils)
library(rgdal)
library(raster)
library(dplyr)
library(stringr)

workingdirectory="D:/Koma/Sync_PhD/_Amsterdam/_PhD/Chapter4_Sentinel/3_Dataprocessing/dataprocess_forpaper_march/radar/merged/"
setwd(workingdirectory)

landcoverfile="D:/Koma/Sync_PhD/_Amsterdam/_PhD/Chapter4_Sentinel/2_Dataset/landcover_filter/landcover/UvA_LGN2018/LGN2018.tif"

# Import
landcover=raster(landcoverfile)

filelist=list.files(pattern = "*.tif")

# create masks

lidar=stack(filelist[1])
proj4string(lidar) <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs")

# landcover

landcover_crop=crop(landcover,extent(lidar))

formask <- setValues(raster(landcover_crop), NA)
formask[landcover_crop==16 |landcover_crop==30 | landcover_crop==41 | landcover_crop==42 | landcover_crop==43 | landcover_crop==45 | landcover_crop==322 | landcover_crop==332] <- 1
proj4string(formask)<- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs")

lgn7_mask_resampled=resample(formask,lidar)
#writeRaster(lgn7_mask_resampled,"lgn7_mask.tif",overwrite=TRUE)
#lgn7_mask_resampled=raster("lgn7_mask.tif")

# apply

for (i in filelist) {
  print(i)
  
  lidar=stack(i)
  proj4string(lidar) <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs")
  
  lidar_masked <- mask(lidar, lgn7_mask_resampled)
  
  getfilename=str_sub(i,1,-5)
  
  writeRaster(lidar_masked,paste(workingdirectory,"/masked2/",getfilename,"_masked.tif",sep=""),overwrite=TRUE)
}