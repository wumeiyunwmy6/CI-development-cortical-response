rm(list = ls())
setwd('D:\\BNU_CI_NIRS\\CSV')
library(tidyverse)
library(lmerTest)
library(emmeans)
library(doBy)
library(bruceR)
library(fdrtool)

## 导入数据，选择条件
mydata_raw0<-read.csv('behaviours.csv',stringsAsFactors = T)
## One factor within
mydata_raw <- mydata_raw0 %>% select('performance1','performance2','performance3') #
names(mydata_raw)[1:3] <- c('C1','C2','C3') ## A: groups, B:condition,1-babble; C: channels,1-ch8 #
MANOVA(na.omit(mydata_raw), dvs = "C1:C3", dvs.pattern = "C(.)",within =c("C")) #%>% EMMEANS("C", by="C")#
t.test(mydata_raw$C1,mydata_raw$C2,paired = TRUE)#,,conditiondataplot2$b 
t.test(mydata_raw$C1,mydata_raw$C3,paired = TRUE)#,,conditiondataplot2$b 
t.test(mydata_raw$C2,mydata_raw$C3,paired = TRUE)#,,conditiondataplot2$b 
     ## plotting
mydata_rawPLOT <- mydata_raw0 %>% select('sub_ID','testT','performance') #
p <- ggplot(mydata_rawPLOT,aes(x=testT,y=performance,color=testT)) +
  geom_boxplot(size=0.6)+ geom_jitter(width = 0.25, height = 0.5,aes(color = testT))+ #position_jitter(width = ,height = )
  scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"))+
  theme_set(theme_bw())+
  theme(panel.grid=element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.ticks.length=unit(-0.4,'cm'),axis.text.y = element_text(margin=unit(c(0.2,0.2,0.2,0.2), "cm")),axis.text.x = element_text(margin=unit(c(0.2,0.2,0.2,0.2), "cm")))+
  theme(axis.ticks.y = element_line(size=1.2, colour = "black"))+
  theme(axis.line = element_line(size=1.2, colour = "black"))+
  theme(axis.text.y = element_text(size = 20,face = 'bold'))+
  theme(axis.text.x = element_text(size = 20,face = 'bold'))
  #theme(axis.text.y = element_text(size = 20,face = 'bold',hjust = 2))vjust = 3)
p 

