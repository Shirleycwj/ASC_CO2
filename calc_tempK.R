# this script calculate depth-averaged soil respiration rate (k) affected by soil temperature
rm(list = ls())
load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/inputs/climate_210127/tmp_0119.rda")
td_top <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_Tdiff_top_210319.csv",header = F)
td_sub <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_respiration_data/soil_Tdiff_sub_210319.csv",header = F)

# calculate damping depth
omega <- 2*pi/12
dd_top <- 2*td_top/omega
dd_sub <- 2*td_sub/omega

# reference tau value from Koven et al. 2017
tau_ref <- 10^(1.1349)
k_ref <- 1/tau_ref
t_ref <- 15

k_mon_avg <- array(NA,dim = c(360,720,1392))

start <- Sys.time()
# running from 1901-2016
for (y in 1901:2016) {
  
  # take 2016 as an example
  start_num <- 1+(y-1901)*12
  end_num <- start_num+11
  
  tmp_y <- climate.d.tran[,,start_num:end_num]
  t_mean <- apply(tmp_y, c(1,2), mean)
  # image(t_mean)
  t_monmax <- apply(tmp_y, c(1,2), max)
  t_monmin <- apply(tmp_y, c(1,2), min)
  t_amp <- (t_monmax-t_monmin)/2 
  
  k_mon_depavg <- array(data = NA, dim = c(360,720,12))
  soiltemp_mon <- array(data = NA, dim = c(360,720,12))
  for (mon in 1:12) {
    k_dep_mon <- array(data = NA, dim = c(360,720,11))
    temp_dep <- array(data = NA, dim = c(360,720,11))
    
    mon_mask <- rbind(matrix(-1,nrow = 180,ncol = 720),matrix(1,nrow = 180,ncol = 720)) * mon
    
    for (dep in seq(0,1,0.1)) {
      
      if (dep <= 0.3) {
        div_dep <- dep/dd_top
        T_dep_mon <- t_mean + t_amp * exp(-div_dep)*sin(omega*mon_mask-div_dep)
        T_dep_mon <- data.matrix(T_dep_mon, rownames.force = NA)
      } else {
        div_dep <- dep/dd_sub
        T_dep_mon <- t_mean + t_amp * exp(-div_dep)*sin(omega*mon_mask-div_dep)
        T_dep_mon <- data.matrix(T_dep_mon, rownames.force = NA)
      }
      
      temp_dep[,,which(dep==seq(0,1,0.1))] <- T_dep_mon
      
      k_dep_mon[,,which(dep==seq(0,1,0.1))] <- k_ref*(1.5^((T_dep_mon-t_ref)/10))
      k_dep_mon[,,which(dep==seq(0,1,0.1))][T_dep_mon<0] <- 0
      
    }
    k_mon_depavg[,,mon] <- apply(k_dep_mon, c(1,2), mean) # soil k is averaged across 1 m depth
    soiltemp_mon[,,mon] <- apply(temp_dep, c(1,2), mean)
  }
  
  k_mon_avg[,,start_num:end_num] <- k_mon_depavg
  
}
end <- Sys.time()
print(end-start)

save(k_mon_avg,file="/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/Rh_simu_210114/soil_temp_k_corr210706.rda")
