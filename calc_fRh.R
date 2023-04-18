# this script calculate the fraction of soil respiration decreased due to soil moisture
rm(list = ls())
setwd("/Users/wenjia/Documents/PhD/ASC_201008_/code_ASC_201009/ASC_CO2/")
library(R.utils)
sourceDirectory('functions', modifiedOnly=FALSE)
# poro.soil <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/GLDAS_poro_210513.csv",
#                       header = F)
poro.soil <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/porosity_210620.csv",
                      header = F)
# optimum water content calculated from soil porosity
op_wc <- poro.soil * 0.65
# clay content of top 1 m soil calculated by weighted topsoil (0-30 cm) and subsoil (30-100 cm)
clay_content <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_sturcture/clay_fullprofile.csv",
                         header = F)
# fwc <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_water_capacity.csv",header = F)
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/inputs/swc_vol_corr_210707.rda")
# fwc[is.na(poro.soil)==T] <- NaN
# for (r in 1:360) {
#   for (c in 1:720) {
#     if (sum(is.na(c(fwc[r,c],poro.soil[r,c])))==0) {
#       if (fwc[r,c]>poro.soil[r,c]) {
#         fwc[r,c] <- poro.soil[r,c]
#       }
#     }
#     
#   }
# }
# calculate collocation factor based on clay content
collo_fac <- matrix(NA,nrow = 360,ncol = 720)
for (r in 1:360) {
  for (c in 1:720) {
    collo_fac[r,c] <- ifelse(is.na(clay_content[r,c])==T,NA,
                             ifelse(clay_content[r,c] <= 0.016,0,
                                    ifelse(clay_content[r,c] <= 0.37,(2.8*clay_content[r,c]-0.046),1)))
  }
}

# initiate soil field capacity as input (soil water content [m3 m−3])
fRh <- array(NA,dim = c(360,720,1416))
for (mon in 1:1416) {
  fwc <- swc_vol_corr[,,mon]
  for (r in 1:360) {
    for (c in 1:720) {
      fRh[r, c,mon] <- ifelse(is.na(fwc[r, c]) == T, NA, ifelse(fwc[r,c] < op_wc[r, c], 
                                                            ((k_theta + op_wc[r, c]) / (k_theta + fwc[r, c])) * ((fwc[r, c] / op_wc[r, c]) ^ (1 + collo_fac[r, c] * ns)),
                                                            ((poro.soil[r, c] - fwc[r, c]) /(poro.soil[r, c] - op_wc[r, c])) ^ b))
    }
  }
  
}

save(fRh,file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_mois_k_210707.rda")


# rm(list = ls())
# load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_mois_k_WISE.rda")
# soil_WISE <- fRh
# rm(fRh)
# load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_mois_k_GLDAS.rda")
# soil_GLDAS <- fRh
# 
# rela_wc <- swc_map[,,1]/poro.soil
# comp <- data.frame(wc = as.vector(data.matrix(rela_wc)),
#                     fRh = as.vector(fRh[,,1]))
# plot(comp$wc,comp$fRh,pch=21,xlim=c(0,1))
# write.map(fRh,"/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/fRh.csv")

