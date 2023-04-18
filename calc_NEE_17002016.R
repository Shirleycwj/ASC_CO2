# this script calculate Ra, Rh and NEE from 1701-2016 using soil carbon from spin-up simulation
rm(list = ls())
setwd("/Users/wenjia/Documents/PhD/ASC_201008_/code_ASC_201009/ASC_CO2/")
library(R.utils)
library(abind)
sourceDirectory('functions', modifiedOnly=FALSE)
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/land_cover_CCI/relaLC_combined.rda")
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/fpe.rda")
gpp.pathway <- "/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/GPP_170016/"

# calculate monthly net primary production (NPP) and autotrophic respiration (Ra)
# relative coverage of PFT, FPE which is the function of climate recyles along with climate during 1701-1900
# unlike spin-up, transient simulation use varying CO2 
ra <- array(NA, dim = c(360,720,3792))
npp <- array(NA, dim = c(360,720,3792))

for (y in 1701:1900) {
  y_num <- (y-1701) %% 20 + 1
  fpe_y <- fpe[,,y_num]
  fac <- abind(rela_cov[,,1]*(1-fpe_y), rela_cov[,,2]*(1-crp), rela_cov[,,3]*(1-oth_veg),along=3)
  fac <- apply(fac,c(1,2),sum,na.rm=TRUE)
  for (m in 1:12) {
    num <- (y-1701)*12+m
    gpp.fname <- paste(gpp.pathway,y,sprintf("%02d",m),".csv",sep = "")
    gpp_mon <- read.csv(gpp.fname,header = F)
    gpp_mon <- data.matrix(gpp_mon)
    
    ra[,,num] <- gpp_mon*fac
    npp[,,num] <- gpp_mon*(1-fac)
  }
}

for (y in 1901:2016) {
  y_num <- y-1900
  fpe_y <- fpe[,,y_num]
  fac <- abind(rela_cov[,,1]*(1-fpe_y), rela_cov[,,2]*(1-crp), rela_cov[,,3]*(1-oth_veg),along=3)
  fac <- apply(fac,c(1,2),sum,na.rm=TRUE)
  for (m in 1:12) {
    num <- (y-1701)*12+m
    gpp.fname <- paste(gpp.pathway,y,sprintf("%02d",m),".csv",sep = "")
    gpp_mon <- read.csv(gpp.fname,header = F)
    gpp_mon <- data.matrix(gpp_mon)
    
    ra[,,num] <- gpp_mon*fac
    npp[,,num] <- gpp_mon*(1-fac)
  }
}

# save(ra,file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/ra_mon_1716.rda")
# save(npp,file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/npp_mon_1716.rda")

rm(list = ls())
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/ra_mon_1716.rda")
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/npp_mon_1716.rda")
############################ use ra and npp to spin-up ################################
# precribed Cveg was used to estiamte fixed kveg throughout the simulation
# cveg is processed with land mask unifying method, see script land_mask.R
cveg_1901 <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/cveg_SDGVM_mask_210620.csv",header = F)
cveg_1901 <- data.matrix(cveg_1901)

npp_1st <- apply(npp[,,1:12], c(1,2), sum, na.rm=TRUE) * 30  # calculate yearly npp
kveg <- npp_1st/cveg_1901
# check Inf value where cveg = 0 (num=1976)
inf_info <- cbind(npp_1st[which(kveg==Inf, arr.ind = T)],cveg_1901[which(kveg==Inf, arr.ind = T)])
kveg[kveg==Inf] <- 0.1 # set Inf kveg as median 0.1
# first approach of cleaning - kveg outliers convert to NA
outlier <- boxplot(as.vector(data.matrix(kveg)))$out
for (i in 1:length(outlier)) {
  kveg[kveg==outlier[i]] <- 0.1  # update: replace outlier with median of kveg (0.1)
}

# load soil respiraiton rate affected by temperature and soil moisture / note that for spin-up we only need first 20 years and use them repeatly
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_mois_k_210707.rda") # update soil_mois_k using porosity calculated by soilgrid_NASA
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_temp_k_corr210706.rda")

# set alpha = 1 as test
alpha = 0.1

# iniate result matrix 
cveg_year <- array(NA, dim = c(360,720, 316))
cveg_year[,,1] <- cveg_1901
csoil_year <- array(NA, dim = c(360,720, 316))
csoil_year[,,1] <- data.matrix(read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha01/csoil_1400y_alpha01.csv",header = F)) # initiate csoil as 0 at the start of spin-up

soil_res <- array(NA, dim = c(360,720, 3792))
soil_k <- array(NA, dim = c(360,720, 3792))
soil_k.round <- array(NA, dim = c(360,720, 240))

for (mon in 1:12) {
  soil_k[,,mon] <- fRh[,,mon] * k_mon_avg[,,mon]
  soil_res[,,mon] <- csoil_year[,,1] * soil_k[,,mon] * alpha
  
}

for (y in 2:200) { # using 20 years of recycling data to run 1701-1900
  cyc.num <- (y-1)%%20+1 # check which year in a cycle 
  mon_cycle_s <- cyc.num*12-11
  mon_cycle_end <- cyc.num*12
  
  mon_s <- y*12-11
  mon_end <- y*12
  
  npp_y <- apply(npp[,,mon_s:mon_end], c(1,2), sum, na.rm=TRUE) * 30
  npp_y[npp_y==0] <- NA
  cveg_year[,,y] <- (cveg_year[,,(y-1)] +  npp_y)/(1+kveg)
  
  for (mon in mon_cycle_s:mon_cycle_end) {
    soil_k.round[,,mon] <- fRh[,,mon] * k_mon_avg[,,mon]
  }
  soil_k[,,mon_s:mon_end] <- soil_k.round[,,mon_cycle_s:mon_cycle_end]
  soil_k.yearly <- apply(soil_k[,,mon_s:mon_end],c(1,2), sum, na.rm=T)
  
  na.num <- apply(soil_k[,,mon_s:mon_end],c(1,2),function(x){sum(is.na(x))})
  soil_k.yearly[na.num==12] <- NA
  
  csoil_year[,,y] <- (csoil_year[,,(y-1)] +  cveg_year[,,y]*kveg)/(1+alpha*soil_k.yearly)
  for (mon_out in mon_s:mon_end) {
    soil_res[,,mon_out] <- csoil_year[,,y] * alpha * soil_k[,,mon_out]
  }
}

soil_k_ann <- array(NA, dim = c(360,720, 1392))
for (y in 201:316) { # using continuous climate data to run 1901-2016
  mon_cli_s <- (y-200)*12-11
  mon_cli_end <- (y-200)*12
  
  mon_s <- y*12-11
  mon_end <- y*12
  
  npp_y <- apply(npp[,,mon_s:mon_end], c(1,2), sum, na.rm=TRUE) * 30
  npp_y[npp_y==0] <- NA
  cveg_year[,,y] <- (cveg_year[,,(y-1)] +  npp_y)/(1+kveg)
  
  for (mon in mon_cli_s:mon_cli_end) {
    soil_k_ann[,,mon] <- fRh[,,mon] * k_mon_avg[,,mon]
  }
  soil_k[,,mon_s:mon_end] <- soil_k_ann[,,mon_cli_s:mon_cli_end]
  soil_k.yearly <- apply(soil_k[,,mon_s:mon_end],c(1,2), sum, na.rm=T)
  
  na.num <- apply(soil_k[,,mon_s:mon_end],c(1,2),function(x){sum(is.na(x))})
  soil_k.yearly[na.num==12] <- NA
  
  csoil_year[,,y] <- (csoil_year[,,(y-1)] +  cveg_year[,,y]*kveg)/(1+alpha*soil_k.yearly)
  for (mon_out in mon_s:mon_end) {
    soil_res[,,mon_out] <- csoil_year[,,y] * alpha * soil_k[,,mon_out]
  }
}
save(soil_res, file="//Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha01/soilres.rda")

rm(list=ls())
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha01/soilres.rda")
library(abind)
soil_res_daily <- soil_res / 30
reco <- array(NA,dim = c(360,720,3792))
for (mon in 1:3792) {
  eres <- abind(soil_res_daily[,,mon],ra[,,mon],along=3)
  reco[,,mon] <- apply(eres, c(1,2), sum, na.rm=T)
  
  na.num <- apply(eres,c(1,2),function(x){sum(is.na(x))})
  reco[,,mon][na.num==2] <- NA
}
save(reco,file = "/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha01/reco.rda")

rm(list=ls())
gpp.pathway <- "/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/GPP_170016/"
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha01/reco.rda")
NEE <- array(NA,dim = c(360,720,3792))
for (y in 1701:2016) {
  for (m in 1:12) {
    num <- (y-1701)*12+m
    gpp.fname <- paste(gpp.pathway,y,sprintf("%02d",m),".csv",sep = "")
    gpp_mon <- read.csv(gpp.fname,header = F)
    gpp_mon <- data.matrix(gpp_mon)
    
    diff <- abind(gpp_mon*(-1),reco[,,num],along = 3)
    NEE[,,num] <- apply(diff, c(1,2), sum)
  }
}


save(NEE, file = "/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha01/NEE.rda")

area <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/inputs/global_area_360720.csv",header = F)
area <- data.matrix(area)

NEE.yearly <- array(NA,dim = c(360,720,316))
NEE.total <- data.frame(year = seq(1701,2016),
                        NEE = NA)
for (i in 1:316) {
  mon_s <- i*12-11
  mon_e <- i*12
  
  NEE.yearly[,,i] <- apply(NEE[,,mon_s:mon_e], c(1,2), sum, na.rm=T)
  NEE.total$NEE[i] <- sum(NEE.yearly[,,i]*area, na.rm=T)*30/1e+15 
}

write.csv(NEE.total,"/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/NEE_total.csv")











