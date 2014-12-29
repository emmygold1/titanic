# created by Fei on 29/12/2015 to compete in the kaggle titanic

rm(list=ls())
graphics.off()
setwd("~/Documents/kaggle/titanic")
dat = read.csv("train.csv", header=T)
dat$Survived = as.factor(dat$Survived)
dat$Pclass = as.factor(dat$Pclass)
mean.age = mean(dat$Age, na.rm=T)
dat$Age.fix = ifelse(is.na(dat$Age), mean.age, dat$Age)
# too many ages missing, replace NA with mean age, as assumed missing is in random
test.dat = read.csv("test.csv", header=T)
test.dat$Pclass = as.factor(test.dat$Pclass)
test.mean.age = mean(test.dat$Age, na.rm=T)
test.dat$Age.fix = ifelse(is.na(test.dat$Age), mean.age, test.dat$Age)
linear.model1 = glm(Survived ~ Pclass + Sex + Age.fix + SibSp + Parch + Fare,
                    data = dat, family='binomial')
# summary showed parch has least significance: largest pr
linear.model2 = update(linear.model1, ~ . - Parch, data=dat, family='binomial')
compare1 = anova(linear.model1, linear.model2, test="Chi")
# looks like parch is truly insignificant
summary(linear.model2)
# summary showed that fare is the least significant now
linear.model3 = glm(Survived ~ Pclass + Sex + Age.fix + SibSp,
                    data = dat, family='binomial')
summary(linear.model3)
linear.model4 = glm(Survived ~ Pclass*Sex*Age.fix*SibSp, data=dat, family='binomial')
summary(linear.model4)
pred = predict(linear.model4, newdata=test.dat, type='response')
summary(pred)
res = data.frame()
