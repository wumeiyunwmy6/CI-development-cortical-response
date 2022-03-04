rm(list = ls())
setwd('D:\\BNU_CI_NIRS\\CSV')
library(tidyverse)
library(lmerTest)
library(emmeans)
library(doBy)
library(bruceR)
library(fdrtool)

## calculate the data(brain)
mydata_raw0<-read.csv('CI-T0_HbOValue_long.csv',stringsAsFactors = T)
mydata_raw <- mydata_raw0 %>% filter(groups%in% c('CI','NH'))%>% filter(condition %in% c('aspeech')) #,'babble','silence'
tvaluedat<-NULL;pvaluedat <- NULL;tpvaluedat <- NULL;dfvaluedat1 <- NULL
correlationss <- colnames(mydata_raw0)[4:23]

##ploting whole brain data
for (i in 1:length(correlationss)){
  conditiondataplot <- mydata_raw %>% select(sub_ID,groups,correlationss[i])# %>% as.data.frame()groups
  conditiondataplot[complete.cases(conditiondataplot),]##???˵???????NAN????
  ## correlation r
  # ##F test
  # result <- summary(aov(conditiondataplot[,5] ~ condition, data = conditiondataplot))
  # aamdcoef <- result[[1]][["Pr(>F)"]][1]
  # fmdcoef <- result[[1]][["F value"]][1]
  # dfmdcoef <- result[[1]][["Df"]]
  # tvaluedat<-rbind(tvaluedat,fmdcoef)
  # pvaluedat <-rbind(pvaluedat,aamdcoef)
  # dfvaluedat1<-rbind(dfvaluedat1,dfmdcoef)
  # pvaluedat2 <- as.numeric(pvaluedat)
  # fdr=fdrtool(pvaluedat2,statistic="pvalue",plot = F)$qval
  # tpvaluedat <- cbind(tvaluedat,pvaluedat,fdr,dfvaluedat1)
  # write.csv(tpvaluedat,'ACT_T0_fdr_3condition.csv')
  ## ttest
  # conditiondataplot2 <- conditiondataplot%>% pivot_wider(names_from=periods3,values_from=correlationss[i])
  CI_t0 <- conditiondataplot %>% filter(groups %in% c('CI'))# filter(periods3 %in% c('t0'))
  NH_tA <- conditiondataplot %>% filter(groups %in% c('NH'))
  statdata <- t.test(NH_tA[,3],CI_t0[,3],paired = FALSE)#,,conditiondataplot2$b
  aamdcoef <-statdata[["p.value"]]
  tmdcoef <- statdata[["statistic"]][["t"]]
  dfmdcoef <- statdata[["parameter"]]
  tvaluedat<-rbind(tvaluedat,tmdcoef)
  pvaluedat <-rbind(pvaluedat,aamdcoef)
  dfvaluedat1<-rbind(dfvaluedat1,dfmdcoef)
  pvaluedat2 <- as.numeric(pvaluedat)
  fdr=fdrtool(pvaluedat2,statistic="pvalue",plot = F)$qval
  tpvaluedat <- cbind(tvaluedat,pvaluedat,fdr,dfvaluedat1)
  write.csv(tpvaluedat,'act_CI30_speech_916.csv')
  # ## LMM and get coef
  # mdstate <- summary(lmer(conditiondataplot[,4] ~ condition  + (1|sub_ID),conditiondataplot,na.action=na.omit))
  # aamdcoef <- mdstate[["coefficients"]][2,5]
  # tmdcoef <- mdstate[["coefficients"]][2,4]
  # tvaluedat<-rbind(tvaluedat,tmdcoef)
  # set threthold to plot
  #  if (aamdcoef<0.05){
  # plts <- ggplot(conditiondataplot ,aes(x=condition,y=conditiondataplot[,4],color=sub_ID,group=sub_ID)) +
  #   ggtitle(label= paste0('t=',tmdcoef),subtitle = paste0('p=',aamdcoef ))+
  #   geom_point(mapping = aes(color = sub_ID),size = 1, alpha=0.7) +
  #   geom_line(aes(colour = sub_ID),alpha=0.2)+
  #   scale_y_continuous(limits = c(-2,2)) +
  #   theme_set(theme_bw())+
  #   theme(panel.grid=element_blank()) +
  #   theme(panel.grid=element_blank())+
  #   theme(panel.border = element_blank())+
  #   theme(axis.line = element_line(size=1, colour = "black"))+
  #   theme(axis.text.x = element_text(size = 15,face = 'bold'))+
  #   theme(axis.text.y = element_text(size = 15,face = 'bold'))
  # #geom_text(aes(label=sub_ID), vjust=-0.2)+ facet_grid(condition ~ lrdata
  # ggsave(paste0('CI29_T0_ACT_sp_Lme-',correlationss[i],'.png'),plts)
#
# data_CI0 <- as.data.frame(conditiondataplot)
# data_CI_mean <-aggregate(data_CI0[,5],by=data_CI0[c('condition')],FUN = mean,na.rm=T)
# colnames(data_CI_mean)[2] <-'meanVbeta'
# data_CI_sd <-aggregate(data_CI0[,5],by=data_CI0[c('condition')],FUN = sd,na.rm=T)
# colnames(data_CI_sd)[2] <- 'SDVbeta'
# data_CI <- merge(data_CI_mean,data_CI_sd)
# p <- ggplot(data_CI,aes(x=condition,y=meanVbeta,fill=condition,alpha=0.5)) +
#   geom_bar(position = 'dodge',stat = 'identity')+
#   geom_errorbar(aes(x=condition, ymin=meanVbeta -SDVbeta/sqrt(29), ymax=meanVbeta + SDVbeta/sqrt(29)),
#                 width=0.3, color='black', position = position_dodge(0.9),size=0.9)  #+coord_cartesian(ylim=c(0.2,0.5))+
# #  ggtitle(label=paste0('NH_35p-',correlationss[i],'-P=',aamdcoef),subtitle = paste0('NH_35p','-t=',fmdcoef))
# #+ facet_wrap( ~ CI,nrow = 2)#+coord_cartesian(ylim=c(0,1.5))+theme_bw()
# plts <- p+theme_set(theme_bw())+theme(panel.grid=element_blank())+
#   scale_y_continuous(limits = c(-0.3,0.6))+
#   theme(panel.border = element_blank())+
#   theme(axis.line = element_line(size=1, colour = "black"))+
#   theme(axis.text.x = element_text(size = 15,face = 'bold'))+
#   theme(axis.text.y = element_text(size = 15,face = 'bold'))# + geom_line()+geom_text(aes(label=sub_ID), vjust=-0.2)
# ggsave(paste0('FC_-',correlationss[i],'.png'),plts)#,width=3.5,height = 3.15
}

## plotting the bar figure to demonstrate the statistical result
mydata_raw00<-read.csv('CI-T0_HbOValue_long.csv',stringsAsFactors = T)
mydata_raw1 <- mydata_raw00 %>% filter(groups%in% c('CI','NH'))%>% mutate(Left=(ch8+ch5)/2,Right=(ch12+ch16)/2) %>% filter(condition %in% c('aspeech','babble'))#
mydata_raw2 <- mydata_raw1 %>% select(groups,Left,Right) %>% pivot_longer(c(Left,Right),names_to = 'Nchs',values_to = 'Nvalues')
data_mean <-aggregate(mydata_raw2$Nvalues,by=mydata_raw2[c('groups','Nchs')],FUN = mean,na.rm=T)
colnames(data_mean)[3] <-'MeanHBO'
data_sd <-aggregate(mydata_raw2$Nvalues,by=mydata_raw2[c('groups','Nchs')],FUN = sd,na.rm=T)
colnames(data_sd)[3] <- 'SDVbeta'
data_CI2 <- merge(data_mean,data_sd)
data_CI <- data_CI2 %>% mutate(Nchs = recode_factor(Nchs,'Left'='LH','Right'='RH'))
p <- ggplot(data_CI,aes(x=Nchs,y=MeanHBO,fill=groups)) +
  geom_bar(position = 'dodge',stat = 'identity',colour='grey')+
  geom_errorbar(aes(x=Nchs, ymin=MeanHBO-SDVbeta/sqrt(35), ymax=MeanHBO + SDVbeta/sqrt(35)),
                width=0.3, color='black', position = position_dodge(0.9),size=0.9)
plts <- p+theme_set(theme_bw())+theme(panel.grid=element_blank())+
  scale_y_continuous(limits = c(-0.1,0.4))+ #c(-0.05,0.2)
  scale_discrete_manual(values=c("tan1","maroon"),aesthetics = 'fill')+#"#5C5DAF",,"red4""red2","blue3"
  theme(panel.border = element_blank())+
  theme(axis.ticks.length=unit(-0.4,'cm'),axis.text.y = element_text(margin=unit(c(0.2,0.2,0.2,0.2), "cm")),axis.text.x = element_text(margin=unit(c(0.2,0.2,0.2,0.2), "cm")))+
  theme(axis.ticks.y = element_line(size=1.2, colour = "black"))+
  theme(axis.line = element_line(size=1.2, colour = "black"))+
  theme(axis.text.x = element_text(size = 15,face = 'bold'))+
  theme(axis.text.y = element_text(size = 20,face = 'bold'))
plts


## LME test group variation
mydata_rawT0 <- mydata_raw1 %>% select(sub_ID,groups,Left,condition,Right) %>% pivot_longer(c(Left,Right),names_to = 'Nchs',values_to = 'Nvalues')
#model_T0<- lmer(Nvalues ~ groups*Nchs*condition + (1|sub_ID),mydata_rawT0,na.action=na.omit)#
model_T0<- lmer(Nvalues ~ groups*condition + groups*Nchs + Nchs*condition + (1|sub_ID),mydata_rawT0,na.action=na.omit)#
summary(model_T0)
anova(model_T0)

# post hoc
emm_md <- emmeans(model_T0, ~ groups*condition)
contrast(emm_md,simple='groups')
emm_md2 <- emmeans(model_T0, ~ Nchs*condition)
contrast(emm_md2,simple='condition')

## statistic MANOVA
mydata_rawA <- mydata_raw1 %>% select('groups','Left','Right')
names(mydata_rawA)[1:3] <- c('A','B1','B2') ## A: groups, B:condition,1-babble; C: channels,1-ch8
MANOVA(na.omit(mydata_rawA), dvs = "B1:B2", dvs.pattern = "B(.)", between="A",within =c("B")) %>% EMMEANS("A", by="B")%>% EMMEANS("B", by="A")

mydata_rawAB <- mydata_raw00 %>% filter(groups%in% c('CI','NH')) %>% select(groups,condition,ch5,ch8,ch12,ch16) %>% filter(condition%in% c('aspeech','babble')
                                        )%>% mutate(Left=(ch8+ch5)/2,Right=(ch12+ch16)/2
                                        ) %>% pivot_longer(c(Left,Right), names_to = 'hemispheres',values_to = 'hvalues'
                                        ) %>% pivot_wider(names_from = c(condition,hemispheres),values_from = 'hvalues'
                                        ) %>% select(groups,aspeech_Left,aspeech_Right,babble_Left,babble_Right)

mydata_rawAB[1:65,2:3] <-mydata_rawAB[66:130,2:3]
mydata_rawAB <- mydata_rawAB[-c(1,65),]
names(mydata_rawAB)[1:5] <- c('A','B1C1','B1C2','B2C1','B2C2') ## A: groups, B:condition,1-babble; C: channels,1-ch8
MANOVA(na.omit(mydata_rawAB), dvs = "B1C1:B2C2", dvs.pattern = "B(.)C(.)", between="A",within =c("B","C")) %>% EMMEANS("A", by="C") %>% EMMEANS(c("A","B"), by="C") %>% EMMEANS("A",by=c("B","C"))



