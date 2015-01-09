# created by Fei on 29/12/2015 to compete in the kaggle titanic

rm(list=ls())
graphics.off()
setwd("~/Documents/kaggle/titanic")
########################################################
# load data
train.dat = read.csv("train.csv", header=T)
test.dat = read.csv("test.csv", header=T)
########################################################
# data cleaning
test.dat$Survived = rep(0, nrow(test.dat))
combo = rbind(train.dat, test.dat)
combo[is.na(combo$Fare),"Fare"] = mean(combo$Fare, na.rm=T)
# fix the only one missing fare with mean fare
combo[combo$Embarked=='',"Embarked"] = 'S'
# fix the only two embark location with S as majority embarked at S
combo.with.age = subset(combo, !is.na(Age))
combo.no.age = subset(combo, is.na(Age))

age.model = glm(Age ~ Pclass + Sex + SibSp, data = combo.with.age)
pred.age = predict(age.model, newdata=combo.no.age)
combo.no.age$Age = ifelse(pred.age >= 0, pred.age, 0)
# fix age

combo = rbind(combo.with.age, combo.no.age)
combo = combo[order(combo$PassengerId), ]
combo$Survived = as.factor(combo$Survived)
combo$Pclass = as.factor(combo$Pclass)
##########################################################
# segment dat into train, cross validation, and test set
set.seed(1)
train.dat = combo[seq(nrow(train.dat)),]
train.dat$group = runif(nrow(train.dat))
train = subset(train.dat, group > .1)
cv = subset(train.dat, group <= .1)
test = combo[(nrow(train.dat)+1):nrow(combo), ]
##########################################################
# logistic regression
model = glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked,
                    data = train, family='binomial')

pred = ifelse(predict(model, newdata=cv) > 0, 1, 0)
length(which(cv$Survived == pred))/nrow(cv)
#####################################################################
# make prediction on test set
pred = ifelse(predict(model, newdata=test) > 0, 1, 0)
res = data.frame(PassengerId = test$PassengerId, Survived = pred)
write.csv(res, "logistic_pred.csv", row.names=F)
