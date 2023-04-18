rm(list = ls())
library(ncdf4)
setwd("/Users/wenjia/Desktop/veg_soil_C_210330")
cveg.fname <- list.files(path = "/Users/wenjia/Desktop/veg_soil_C_210330/",pattern = "*cVeg.nc")

fit <- c(4,5,9,10,11,13,15)
cveg_whole <- array(NA, dim = c(360,720,7))


  nc_name <- cveg.fname[15] # choose SDGVM due to  same spatial resolution
  rdata <- nc_open(nc_name)
  print(rdata)

  cveg <- ncvar_get(rdata,"cVeg")
  cveg_1901 <- apply(t(cveg[,,202]),2,rev)
  
  cveg_whole[,,7] <- cveg_1901
  # hist(cveg_1901)
  print(cveg_1901[35,164])


save(cveg_whole, file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/cveg_TRENDY.rda")

