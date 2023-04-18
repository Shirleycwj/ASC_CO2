# this script calculate Ra and NPP based on global GPP
rm(list = ls())
setwd("/Users/wenjia/Documents/PhD/ASC_201008_/code_ASC_201009/ASC_CO2/")
library(R.utils)
library(abind)
sourceDirectory('functions', modifiedOnly=FALSE)
gpp_path <- "/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/gpp_annual/"
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/land_cover_CCI/relaLC_combined.rda")
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/fpe.rda")

# rda_file <- list.files(path = "/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/land_cover/rela_lc",
#                        pattern = "*.rda")
# for (num in 1:length(rda_file)) {
#   load(paste("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/land_cover/rela_lc/",rda_file,sep = "")[num])
# }

################
# for (i in 1:110) {
#   gpp <- read.csv(paste(gpp_path,(i+1900),".csv",sep = ""),header = F)
#   gpp <- data.matrix(gpp)
#   
#   # fpe_y <- fpe[,,i]
#   # forest_cover <- relalc.forest[,,i]
#   # grass_cover <- relalc.grass[,,i]
#   # savanna_cover <- relalc.savanna[,,i]
#   # tundra_cover <- relalc.tundra[,,i]
#   # pas_cover <- relalc.patr[,,i]
#   # crop_cover <- relalc.crop[,,i]
#   # shrub_cover <- relalc.shrub[,,i]
#   # 
#   # fac <- forest_cover*(1-fpe_y)+ grass_cover*(1-grs) + 
#   #   savanna_cover*(1-svana) + tundra_cover*(1-tdra)+ 
#   #   pas_cover*(1-grs) + crop_cover*(1-crp) + shrub_cover*(1-shrb)  # treat pasture as grassland for compatibility reasons
#   cover <- abind(relalc.forest[,,i],relalc.grass[,,i],relalc.savanna[,,i],relalc.tundra[,,i],relalc.patr[,,i],
#                  relalc.crop[,,i],relalc.shrub[,,i],along = 3)
#   HYDE_bpe <- list(fpe[,,i],grs,svana,tdra,grs,crp,shrb)
#   fac <- abind(cover[,,1]*(1-HYDE_bpe[[1]]),cover[,,2]*(1-HYDE_bpe[[2]]),cover[,,3]*(1-HYDE_bpe[[3]]),
#                cover[,,4]*(1-HYDE_bpe[[4]]),cover[,,5]*(1-HYDE_bpe[[5]]),cover[,,6]*(1-HYDE_bpe[[6]]),cover[,,7]*(1-HYDE_bpe[[7]]),along = 3)
#   fac <- apply(fac,c(1,2),sum,na.rm=TRUE)
#   ra <- gpp*fac
#   Ra[,,i] <- ra
# }
# 
# # forest.ra <- gpp * forest_cover*(1-fpe_y)
# # grass.ra <- gpp *  grass_cover*(1-grs)
# # savanna.ra <- gpp * savanna_cover*(1-svana)
# # tundra.ra <- gpp * tundra_cover*(1-tdra)
# # pas.ra <- gpp * pas_cover*(1-grs)
# # crop.ra <- gpp * crop_cover*(1-crp)
# # shrub.ra <- gpp * shrub_cover*(1-shrb)
# # cover <- forest_cover+grass_cover+savanna_cover+tundra_cover+pas_cover+crop_cover+shrub_cover
# 
# 
# for (j in 111:116) {
#   gpp <- read.csv(paste(gpp_path,(j+1900),".csv",sep = ""),header = F)
#   gpp <- data.matrix(gpp)
#   
#   # fpe_y <- fpe[,,j]
#   # forest_cover <- rela.forest[,,(j-110)]
#   # grass_cover <- rela.grass[,,(j-110)]
#   # savanna_cover <- rela.savanna[,,(j-110)]
#   # crop_cover <- rela.crop[,,(j-110)]
#   # shrub_cover <- rela.shrub[,,(j-110)]
#   # 
#   # fac <- forest_cover*(1-fpe_y)+ grass_cover*(1-grs) + 
#   #   savanna_cover*(1-svana) + crop_cover*(1-crp) + shrub_cover*(1-shrb)
#   cover <- abind(rela.forest[,,(j-110)],rela.grass[,,(j-110)],rela.savanna[,,(j-110)],rela.crop[,,(j-110)],rela.shrub[,,(j-110)],along = 3)
#   MODIS_bpe <- list(fpe[,,j],grs,svana,crp,shrb)
#   fac <- abind(cover[,,1]*(1-MODIS_bpe[[1]]),cover[,,2]*(1-MODIS_bpe[[2]]),cover[,,3]*(1-MODIS_bpe[[3]]),
#                cover[,,4]*(1-MODIS_bpe[[4]]),cover[,,5]*(1-MODIS_bpe[[5]]),along = 3)
#   fac <- apply(fac,c(1,2),sum,na.rm=TRUE)
#   ra <- gpp*fac
#   Ra[,,j] <- ra
#   
# }
######################
Ra <- array(NA, dim = c(360,720,116))
for (i in 1:116) {
  gpp <- read.csv(paste(gpp_path,(i+1900),".csv",sep = ""),header = F)
  gpp <- data.matrix(gpp)
  
  fpe_y <- fpe[,,i]
  fac <- abind(rela_cov[,,1]*(1-fpe_y), rela_cov[,,2]*(1-crp), rela_cov[,,3]*(1-oth_veg),along=3)
  fac <- apply(fac,c(1,2),sum,na.rm=TRUE)
  
  ra <- gpp*fac
  Ra[,,i] <- ra
}


ra_total <- data.frame(year = seq(1901,2016),
                       ra = NA)
for (year in 1:116) {
  ra_total$ra[year] <- calc_totalGPP(Ra[,,year])
}


# save(Ra,file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/ra_210511.rda")
# write.csv(ra_total,"/Users/wenjia/Desktop/ra_210511.csv",row.names = F)

# calculate monthly autotrophic respiration
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/gpp_monthly.rda") # load monthly daily average GPP (gC /m2 day)
ra <- array(NA, dim = c(360,720,1392))
for (i in 1:116) {
  
  
  fpe_y <- fpe[,,i]
  fac <- abind(rela_cov[,,1]*(1-fpe_y), rela_cov[,,2]*(1-crp), rela_cov[,,3]*(1-oth_veg),along=3)
  fac <- apply(fac,c(1,2),sum,na.rm=TRUE)
  
  for (m in 1:12) {
    mon <- (i-1)*12+m
    gpp <- gpp_mon[,,mon]
    ra_mon <- gpp*fac
    ra[,,mon] <- ra_mon
  }
}

save(ra,file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Ra_simu/global_1901_2016/ra_mon.rda")






