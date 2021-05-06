# this script calculate global total annual GPP (Pg C/yr) based on global annual GPP (g C/m2 yr)

calc_totalGPP <- function(globalG) {
  grid_area <- read.csv("./functions/global_area_360720.csv",header = F)
  globalG[is.na(globalG)==T] <- 0
  total_gpp <- globalG * grid_area
  global_gpp <- sum(total_gpp)/(1e+15)
  
  global_gpp
}



   
  
 


