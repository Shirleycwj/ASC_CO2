rm(list =ls())
library(ncdf4)
# setwd("/Users/wenjia/Desktop/veg_soil_C_210330")
# # load vegetation biomass carbon
# cveg.fname <- list.files(path = "/Users/wenjia/Desktop/veg_soil_C_210330/",pattern = "*cVeg.nc")
# nc_name <- cveg.fname[15] # choose SDGVM due to same spatial resolution
# rdata <- nc_open(nc_name)
# cveg <- ncvar_get(rdata,"cVeg")
# cveg_1901 <- apply(t(cveg[,,202]),2,rev) # choose Cveg of year 1901
# cveg_1901 <- cveg_1901 * 1000 # convert kg/m2 to g/m2
# 
write.map <- function(file,path) {
  write.table(file, path,sep = ",",na="NaN",row.names = F,col.names = F)
}

# cveg is processed with land mask unifying method, see script land_mask.R
cveg_1901 <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/cveg_SDGVM_mask_210620.csv",header = F)
cveg_1901 <- data.matrix(cveg_1901)

# calculate vegetation carbon turnover rate
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/npp_mon_210512.rda")
npp_1901 <- apply(npp[,,1:12], c(1,2), sum, na.rm=TRUE) * 30  # calculate yearly npp
kveg <- npp_1901/cveg_1901
kveg[kveg==Inf] <- NA
# first approach of cleaning - kveg outliers convert to NA
outlier <- boxplot(as.vector(data.matrix(kveg)))$out
# for (i in 1:length(outlier)) {
#        a = (cveg_1901[which(kveg==outlier[i])])
#        if (a<0.1) {
#          print(a)
#        }
#   }
for (i in 1:length(outlier)) {
  kveg[kveg==outlier[i]] <- 0.1  # update: replace outlier with median of kveg (0.1)
}
# second approach of cleaning - kveg>1 assigned to NA, kveg<1 but classified as outlier consiste half of total number of outliers
# kveg[kveg>1] <- NA

# load soil carbon 
csoil_nc <- nc_open("/Users/wenjia/Desktop/veg_soil_C_210330/SDGVM_S2_cSoil.nc")
csoil <- ncvar_get(csoil_nc,"cSoil")
csoil_1901 <- apply(t(csoil[,,202]),2,rev) * 1000
# check and fix NA and negative values
for (i in 2:359) {
  for (j in 2:719) {
    c = csoil_1901[(i-1):(i+1),(j-1):(j+1)]
    if (is.na(csoil_1901[i,j])==T) {
      csoil_1901[i,j] <- mean(c[c>min(c) & c<max(c)],na.rm=T)
    } else if (csoil_1901[i,j]<0) {
      csoil_1901[i,j] <- mean(c[c>min(c) & c<max(c)],na.rm=T)
    }
  }
}
# fix the outlier (maximum value of 2498035 g/m2)
which(csoil_1901==max(csoil_1901,na.rm = T),arr.ind = T)
c_app <- csoil_1901[210:212,218:220]
csoil_1901[211,219] <- mean(c_app[c_app>min(c_app) & c_app<max(c_app)],na.rm=T)

# load soil respiraiton rate affected by temperature and soil moisture
# load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_mois_k.rda")
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_mois_k_210620.rda") # update soil_mois_k using porosity calculated by soilgrid_NASA
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_temp_k.rda")

# iniate result matrix
cveg_year <- array(NA, dim = c(360,720, 116))
cveg_year[,,1] <- cveg_1901
csoil_year <- array(NA, dim = c(360,720, 116))
csoil_year[,,1] <- csoil_1901

soil_res <- array(NA, dim = c(360,720, 1392))
soil_k <- array(NA, dim = c(360,720, 1392))

alpha = 0.1
for (mon in 1:12) {
  soil_k[,,mon] <- fRh[,,mon] * k_mon_avg[,,mon]
  soil_res[,,mon] <- csoil_year[,,1] * soil_k[,,mon] * alpha
  
}

for (y in 1902:2016) {
  mon_s <- (y-1900)*12-11
  mon_end <- (y-1900)*12
  
  npp_y <- apply(npp[,,mon_s:mon_end], c(1,2), sum, na.rm=TRUE) * 30
  # npp_y <- apply(npp[,,1:12], c(1,2), sum, na.rm=TRUE) * 30
  
  npp_y[npp_y==0] <- NA
  cveg_year[,,(y-1900)] <- (cveg_year[,,(y-1901)] +  npp_y)/(1+kveg)
  
  for (mon in mon_s:mon_end) {
   soil_k[,,mon] <- fRh[,,mon] * k_mon_avg[,,mon]
  }
  # soil_k[,,mon_s:mon_end] <- soil_k[,,1:12]
  soil_k.yearly <- apply(soil_k[,,mon_s:mon_end],c(1,2), sum, na.rm=T)
  
  na.num <- apply(soil_k[,,mon_s:mon_end],c(1,2),function(x){sum(is.na(x))})
  soil_k.yearly[na.num==12] <- NA
  
  csoil_year[,,(y-1900)] <- (csoil_year[,,(y-1901)] +  cveg_year[,,(y-1900)]*kveg)/(1+alpha*soil_k.yearly)
  for (mon in mon_s:mon_end) {
    soil_res[,,mon] <- csoil_year[,,(y-1900)] * alpha * soil_k[,,mon]
  }
}


# cveg_1902 <- array(NA, dim = c(360,720))
# npp_1902 <- apply(npp[,,13:24], c(1,2), sum, na.rm=TRUE) * 30
# npp_1902[npp_1902==0] <- NA
# cveg_1902 <- (cveg_1901 +  npp_1902)/(1+kveg)
# save(csoil_year, file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/results_v1.2/csoil_alpha1.rda")
save(soil_res, file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/results_v1.2/soilres_alpha01.rda")

