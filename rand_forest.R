# created on 10/01/2015 for kaggle titanic, tinkering with random forest
######################################################
##### load data
# install.packages('party')
library(party)
rm(list=ls())
graphics.off()
setwd("~/Documents/kaggle/titanic")
train = read.csv("train.csv", header=T)
test = read.csv("test.csv", header=T)
#########################################################
##### data cleaning
test$Survived = NA
combo = rbind(train, test)

combo$Name = as.character(combo$Name)
combo$Title = sapply(combo$Name,
                     FUN=function(x) {strsplit(x, split='[,.]')[[1]][2]})
combo$Title = sub(' ', '', combo$Title)
table(combo$Title)
combo$Title[combo$Title %in% c('Mme', 'Mlle')] = 'Mlle'
combo$Title[combo$Title %in% c('Capt', 'Don', 'Major', 'Sir')] = 'Sir'
combo$Title[combo$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] = 
  'Lady'
combo$Title = factor(combo$Title)

combo$FamilySize = combo$SibSp + combo$Parch + 1
combo$Surname = sapply(combo$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
combo$FamilyID = paste(as.character(combo$FamilySize), combo$Surname, sep="")
famIDs = data.frame(table(combo$FamilyID))
famIDs = famIDs[famIDs$Freq <= 2,]
combo$FamilyID[combo$FamilyID %in% famIDs$Var1] = 'Small'
combo$FamilyID = factor(combo$FamilyID)
## fix age, embarked, and fare
Agefit = rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title +
                 FamilySize,
                data=combo[!is.na(combo$Age),], method="anova")
combo$Age[is.na(combo$Age)] = predict(Agefit, combo[is.na(combo$Age),])
combo$Embarked[which(combo$Embarked == '')] = "S"
combo$Embarked <- factor(combo$Embarked)
combo$Fare[which(is.na(combo$Fare))] <- median(combo$Fare, na.rm=TRUE)
# combo$FamilyID2 <- combo$FamilyID
# combo$FamilyID2 <- as.character(combo$FamilyID2)
# combo$FamilyID2[combo$FamilySize <= 3] <- 'Small'
# combo$FamilyID2 <- factor(combo$FamilyID2)
#######################################
## split again
train = combo[seq(nrow(train)),]
test = combo[(nrow(train)+1):nrow(combo),]
###### grow forest
set.seed(1)
# fit <- randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize +
#                       FamilyID2, data=train, importance=TRUE, ntree=2000)
# varImpPlot(fit)
fit <- cforest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID,
               data = train, controls=cforest_unbiased(ntree=2000, mtry=3))
############################################
#### make prediction and persist result
pred = predict(fit, test, OOB=TRUE, type = "response")
submit = data.frame(PassengerId = test$PassengerId, Survived = pred)
write.csv(submit, file = "rand_forest.csv", row.names = FALSE)
