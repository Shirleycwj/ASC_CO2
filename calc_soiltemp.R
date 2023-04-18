rm(list = ls())
library(raster)
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/inputs/climate_210127/tmp_0119.rda")

# retrive soil properties
soil <- brick("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/inputs/soil_50Km+nasa.nc")
# layer 1-6 correspond to sand, clay, SOM, coarse fraction, bulk density, soil thickness
fsand <- raster::as.matrix(soil[[1]]) # sand fraction
fclay <- raster::as.matrix(soil[[2]]) # clay fraction
fsilt <- 1-fsand-fclay

# calculate thermal diffusivity of soil components
td <- 0.815*fclay+0.946*fsilt+1.760*fsand

# calculate damping depth
omega <- 2*pi/12
dd <- 2*td/omega 

# initiate output
stemp <- array(NA,dim = c(360,720,1392))
for (y in 1901:2016) {
  start_num <- 1+(y-1901)*12
  end_num <- start_num+11
  
  tmp_y <- climate.d.tran[,,start_num:end_num]
  t_mean <- apply(tmp_y, c(1,2), mean)
  t_monmax <- apply(tmp_y, c(1,2), max)
  t_monmin <- apply(tmp_y, c(1,2), min)
  t_amp <- (t_monmax-t_monmin)/2 
  
  stemp_mon <- array(data = NA, dim = c(360,720,12))
  for (mon in 1:12) {
    mon_mask <- rbind(matrix(-1,nrow = 180,ncol = 720),matrix(1,nrow = 180,ncol = 720)) * mon
    
    stemp_depth <- array(data = NA, dim = c(360,720,11))
    for (dep in c(0,1,0.1)) {
      div_dep <- dep/dd
      stemp_depth[,,(dep/0.1 + 1)] <- t_mean + t_amp * exp(-div_dep)*sin(omega*mon_mask-div_dep)
    }
    
    stemp_mon[,,mon] <- apply(stemp_depth, c(1,2), mean, na.rm=T)
    
  }
  stemp[,,start_num:end_num] <- stemp_mon
}

save(stemp,file = "/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_SOMic/soil_temp_mon.rda")




