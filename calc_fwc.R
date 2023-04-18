rm(list = ls())
setwd("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/")

clay_top <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/clay_top.csv",
                     header = F)
clay_sub <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/clay_sub.csv",
                     header = F)
sand_top <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/sand_top.csv",
                     header = F)
sand_sub <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/sand_sub.csv",
                     header = F)
orgc_top <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/orgc_top.csv",
                     header = F)
orgc_sub <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/orgc_sub.csv",
                     header = F)
# clay content of top 1 m soil calculated by weighted topsoil (0-30 cm) and subsoil (30-100 cm)
clay <- abind(clay_top * 0.3,clay_sub * 0.7,along = 3)
clay_ff <- apply(clay, c(1,2), sum, na.rm=T)
# sand content of top 1 m soil calculated by weighted topsoil (0-30 cm) and subsoil (30-100 cm)
sand <- abind(sand_top * 0.3,sand_sub * 0.7,along = 3)
sand_ff <- apply(sand, c(1,2), sum, na.rm=T)
# organic carbon content of top 1 m soil calculated by weighted topsoil (0-30 cm) and subsoil (30-100 cm)
orgc <- abind(orgc_top * 0.3,orgc_sub * 0.7,along = 3)
orgc_ff <- apply(orgc, c(1,2), sum, na.rm=T)

kfc <- -0.251*sand_ff + 0.195*clay_ff + 0.011*orgc_ff + 0.006*sand_ff*orgc_ff - 0.027*clay_ff*orgc_ff + 0.452*sand_ff*clay_ff + 0.299
wfc <- kfc + (1.283*(kfc^2) - 0.374*kfc - 0.015)

write.map <- function(file,path) {
  write.table(file, path,sep = ",",na="NaN",row.names = F,col.names = F)
}
write.map(wfc,"/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_water_capacity.csv")
write.map(clay_ff,"/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/clay_fullprofile.csv")
