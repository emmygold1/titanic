# created on 8/01/2015 for kaggle titanic, tinkering decision trees
# install.packages('rattle')
# install.packages('rpart.plot')
# install.packages('RColorBrewer')
# library(rattle)
# library(rpart.plot)
# library(RColorBrewer)
######################################################
# load data
rm(list=ls())
graphics.off()
setwd("~/Documents/kaggle/titanic")
train = read.csv("train.csv", header=T)
test = read.csv("test.csv", header=T)
######################################################
# data managing
test$Survived = NA
combo = rbind(train, test)

combo$Name = as.character(combo$Name)
combo$Title = sapply(combo$Name,
                     FUN=function(x) {strsplit(x, split='[,.]')[[1]][2]})
combo$Title = sub(' ', '', combo$Title)
table(combo$Title)
combo$Title[combo$Title %in% c('Mme', 'Mlle')] = 'Mlle'
combo$Title[combo$Title %in% c('Capt', 'Don', 'Major', 'Sir')] = 'Sir'
combo$Title[combo$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] = 'Lady'
combo$Title = factor(combo$Title)

combo$FamilySize = combo$SibSp + combo$Parch + 1
combo$Surname = sapply(combo$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
combo$FamilyID = paste(as.character(combo$FamilySize), combo$Surname, sep="")
famIDs = data.frame(table(combo$FamilyID))
famIDs = famIDs[famIDs$Freq <= 2,]
combo$FamilyID[combo$FamilyID %in% famIDs$Var1] = 'Small'
combo$FamilyID = factor(combo$FamilyID)
#######################################
## split again
train = combo[seq(nrow(train)),]
test = combo[(nrow(train)+1):nrow(combo),]
##########################################
set.seed(1)
train$group = runif(nrow(train))
train.set = subset(train, group > .1)
cv.set = subset(train, group <= .1)
fit = rpart(Survived ~ Pclass + Sex + Age + SibSp +
               Parch + Fare + Embarked + Title + FamilySize + FamilyID,
            data=train.set, method="class")
pred = predict(fit, cv.set, type = "class")
length(which(cv.set$Survived == pred))/nrow(cv.set)
# plot(fit)
# text(fit)
# fancyRpartPlot(fit)
pred = predict(fit, test, type = "class")
submit = data.frame(PassengerId = test$PassengerId, Survived = pred)
write.csv(submit, file = "dtree.csv", row.names = FALSE)