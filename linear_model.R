# created by Fei on 29/12/2015 to compete in the kaggle titanic

rm(list=ls())
graphics.off()
setwd("~/Documents/kaggle/titanic")
dat = read.csv("train.csv", header=T)
linear_model1 = lm()
dat$Survived = as.factor(dat$Survived)
dat$Pclass = as.factor(dat$Pclass)
