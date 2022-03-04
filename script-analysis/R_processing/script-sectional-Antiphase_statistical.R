rm(list = ls())
setwd('D:\\BNU_CI_NIRS\\CSV')
library(tidyverse)
library(lmerTest)
library(emmeans)
library(doBy)
library(bruceR)
library(fdrtool)

## 导入数据，选择条件
mydata_raw0<-read.csv('activity_conditions_groups_lmm.csv',stringsAsFactors = T)
## One factor within
#mutate(K=apply(df,1,function(x)mean(x,na.rm=TRUE)))%>%
mydata_raw <- mydata_raw0 %>%filter(Pts=='t4')  %>% select('LTvaluesS','LTvaluesB') #
names(mydata_raw)[1:2] <- c('C1','C2') ## A: groups, B:condition,1-babble; C: channels,1-ch8 #
MANOVA(na.omit(mydata_raw), dvs = "C1:C2", dvs.pattern = "C(.)",within =c("C")) #%>% EMMEANS("C", by="C")#
t.test(mydata_raw$C1,mydata_raw$C2,paired = TRUE)#,,conditiondataplot2$b 
sqrt( 0.14 / (1 - 0.14) ) #Cohen’
sqrt(5.55)

## 使用混合线性
model_AT<- lmer(Ltvalues ~ Pts*Conditions + (1|sub_ID),mydata_raw0,na.action=na.omit)#
summary(model_AT)
anova(model_AT)
# 简单效应
emm_md_AT <- emmeans(model_AT, ~ Pts*Conditions)
contrast(emm_md_AT,simple='Conditions')

## 使用混合线性(单个时期分别进行)
mydata_raw6 <- mydata_raw0 %>% filter(Pts=='t4')
model_AT6<- lmer(Ltvalues ~ Conditions + (1|sub_ID),mydata_raw6,na.action=na.omit)#
summary(model_AT6)

## TWO factor within
#mutate(K=apply(df,1,function(x)mean(x,na.rm=TRUE)))%>%
mydata_raw <- mydata_raw0 %>%filter(Pts=='t4')  %>% select('LTvaluesS','LTvaluesB','RTvaluesS','RTvaluesB') #
names(mydata_raw)[1:4] <- c('B1C1','B1C2','B2C1','B2C2') ## A: groups, B:condition,1-babble; C: channels,1-ch8 #
MANOVA(na.omit(mydata_raw), dvs = "B1C1:B2C2", dvs.pattern = "B(.)C(.)",within =c("B","C")) %>% EMMEANS("C", by="B")#

# two factor: one is within, another is between
mydata_raw <- mydata_raw0 %>%filter(Pts=='t1') %>% select('group','LTValuesS','LTValuesB')
names(mydata_raw)[1:3] <- c('A','B1','B2') ## A: groups, B:condition,1-babble; C: channels,1-ch8
MANOVA(na.omit(mydata_raw), dvs = "B1:B2", dvs.pattern = "B(.)", between="A",within =c("B")) %>% EMMEANS("A", by="B")%>% EMMEANS("B", by="A")

# three factor: two are within, another is between
#mutate(K=apply(df,1,function(x)mean(x,na.rm=TRUE)))%>%
mydata_raw <- mydata_raw %>% select('groups','ch5BA','ch12BA','ch5SP','ch12SP') 
names(mydata_raw)[1:5] <- c('A','B1C1','B1C2','B2C1','B2C2') ## A: groups, B:condition,1-babble; C: channels,1-ch8
MANOVA(na.omit(mydata_raw), dvs = "B1C1:B2C2", dvs.pattern = "B(.)C(.)", between="A",within =c("B","C")) %>% EMMEANS("A", by="B") %>% EMMEANS(c("A","B"), by="C") %>% EMMEANS("A",by=c("B","C"))

## plotting
mydata_raw2 <- mydata_raw0 %>%filter(Pts=='t1') %>% select('LTvaluesS','LTvaluesB','RTvaluesS','RTvaluesB') 
data_mean <-apply(mydata_raw2,2,mean,na.rm=T)
data_sd <-apply(mydata_raw2,2,sd,na.rm=T)
data_CI2 <- rbind(data_mean,data_sd)%>% as.data.frame()
data_CI2$type[1] <- 'MeanHBO'
data_CI2$type[2] <- 'SDVbeta'
data_CI <- data_CI2 %>% pivot_longer(cols = c('LTvaluesS','LTvaluesB','RTvaluesS','RTvaluesB'),names_to = 'LSN',values_to = 'LSV'
                      ) %>%  mutate(HEMISPHERES = recode_factor(LSN,'LTvaluesS'='LH','RTvaluesS'='RH','LTvaluesB'='LH','RTvaluesB'='RH')
                      ) %>%  mutate(CONDITIONS = recode_factor(LSN,'LTvaluesS'='SP','RTvaluesS'='SP','LTvaluesB'='BA','RTvaluesB'='BA')
                      ) %>% pivot_wider(names_from = type,values_from = LSV)


p <- ggplot(data_CI,aes(x=HEMISPHERES,y=MeanHBO,fill=CONDITIONS)) +
  geom_bar(position = 'dodge',stat = 'identity',colour='grey')+
  geom_errorbar(aes(x=HEMISPHERES, ymin=MeanHBO-SDVbeta/sqrt(21), ymax=MeanHBO + SDVbeta/sqrt(21)),
                width=0.3, color='black', position = position_dodge(0.9),size=0.9)
plts <- p+theme_set(theme_bw())+theme(panel.grid=element_blank())+
  scale_y_continuous(limits = c(-0.2,0.4))+
  scale_discrete_manual(values=c("red2","blue3"),aesthetics = 'fill')+#"#5C5DAF"
  theme(panel.border = element_blank())+
  theme(axis.ticks.length=unit(-0.4,'cm'),axis.text.y = element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),axis.text.x = element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")))+
  theme(axis.ticks.y = element_line(size=1.2, colour = "black"))+
  theme(axis.line = element_line(size=1.2, colour = "black"))+
  theme(axis.text.x = element_text(size = 15,face = 'bold'))+
  theme(axis.text.y = element_text(size = 20,face = 'bold'))
plts

