rm(list = ls())
library(maptools)
library(maps)
library(reshape2)
library(ggplot2)
library(scales)
library(RColorBrewer)

load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha1/NEE.rda")
NEE_2016 <- apply(NEE[,,3781:3792], c(1,2), sum, na.rm=T) * 30
# hist(NEE_2016)
 

P = t(NEE_2016)
longDataP<-melt(P)
longDataP$Var1 <- rep(seq(-179.75,179.75,0.5),360)
longDataP$Var2 <- rep(seq(-89.75,89.75,0.5),each = 720)
longDataP<-longDataP[longDataP$value!=0,]

mp <- NULL #定义一个空的地图
mapworld <- borders("world",colour = "gray50",fill="white") #绘制基本地图
mp <- ggplot()+mapworld+ylim(-90,90) + theme_minimal()

mp2 <- mp + geom_tile(data = longDataP, aes(x = Var1, y = -Var2,fill=value),inherit.aes = T, show.legend = T) + 
  scale_fill_viridis(limits=c(-100, 100),oob=squish) +
  labs(x="latitude", y="longitude", fill="NEE (g C/m2 yr)") +
  scale_y_continuous(breaks=seq(90,-90,-30))+
  scale_x_continuous(breaks=seq(-180,180,60)) +
  theme_minimal() + 
  theme(legend.position = "bottom") +
  guides(fill = guide_colourbar(barwidth = 15, barheight = 0.5))
mp2


load("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/alpha1/reco.rda")
reco_2016 <- apply(reco[,,3781:3792], c(1,2), sum, na.rm=T) * 30

P = t(reco_2016)
longDataP<-melt(P)
longDataP$Var1 <- rep(seq(-179.75,179.75,0.5),360)
longDataP$Var2 <- rep(seq(-89.75,89.75,0.5),each = 720)
longDataP<-longDataP[longDataP$value!=0,]

mp <- NULL #定义一个空的地图
mapworld <- borders("world",colour = "gray50",fill="white") #绘制基本地图
mp <- ggplot()+mapworld+ylim(-90,90) + theme_minimal()

mp2 <- mp + geom_tile(data = longDataP, aes(x = Var1, y = -Var2,fill=value),inherit.aes = T, show.legend = T) + 
  scale_fill_viridis(limits=c(0, 3000),oob=squish) +
  labs(x="latitude", y="longitude", fill="Reco (g C/m2 yr)") +
  scale_y_continuous(breaks=seq(90,-90,-30))+
  scale_x_continuous(breaks=seq(-180,180,60)) +
  theme_minimal() + 
  theme(legend.position = "bottom") +
  guides(fill = guide_colourbar(barwidth = 15, barheight = 0.5))
mp2

# for (num in 3781:3792) {
#   NEE[,,num][NEE[,,num]==0] <- NA
#   image(NEE[,,num])
# }

gpp_2016 <- read.csv("/Users/wenjia/Documents/PhD/ASC_201008_/global_simulation_201203/recalc_trendy/GPP_170016/2016.csv", header = F)
gpp_2016 <- as.matrix(gpp_2016)
gpp_2016[gpp_2016==0] <- NA

P = t(gpp_2016)
longDataP<-melt(P)
longDataP$Var1 <- rep(seq(-179.75,179.75,0.5),360)
longDataP$Var2 <- rep(seq(-89.75,89.75,0.5),each = 720)
longDataP<-longDataP[longDataP$value!=0,]

mp <- NULL #定义一个空的地图
mapworld <- borders("world",colour = "gray50",fill="white") #绘制基本地图
mp <- ggplot()+mapworld+ylim(-90,90) + theme_minimal()

mp2 <- mp + geom_tile(data = longDataP, aes(x = Var1, y = -Var2,fill=value),inherit.aes = T, show.legend = T) + 
  scale_fill_viridis(limits=c(0, 3500),oob=squish) +
  labs(x="latitude", y="longitude", fill="Reco (g C/m2 yr)") +
  scale_y_continuous(breaks=seq(90,-90,-30))+
  scale_x_continuous(breaks=seq(-180,180,60)) +
  theme_minimal() + 
  theme(legend.position = "bottom") +
  guides(fill = guide_colourbar(barwidth = 15, barheight = 0.5))
mp2

diff <- reco_2016 - gpp_2016
P = t(diff)
longDataP<-melt(P)
longDataP$Var1 <- rep(seq(-179.75,179.75,0.5),360)
longDataP$Var2 <- rep(seq(-89.75,89.75,0.5),each = 720)
longDataP<-longDataP[longDataP$value!=0,]

mp <- NULL #定义一个空的地图
mapworld <- borders("world",colour = "gray50",fill="white") #绘制基本地图
mp <- ggplot()+mapworld+ylim(-90,90) + theme_minimal()

mp2 <- mp + geom_tile(data = longDataP, aes(x = Var1, y = -Var2,fill=value),inherit.aes = T, show.legend = T) + 
  scale_fill_viridis(limits=c(-100,100),oob=squish) +
  labs(x="latitude", y="longitude", fill="Reco (g C/m2 yr)") +
  scale_y_continuous(breaks=seq(90,-90,-30))+
  scale_x_continuous(breaks=seq(-180,180,60)) +
  theme_minimal() + 
  theme(legend.position = "bottom") +
  guides(fill = guide_colourbar(barwidth = 15, barheight = 0.5))
mp2










