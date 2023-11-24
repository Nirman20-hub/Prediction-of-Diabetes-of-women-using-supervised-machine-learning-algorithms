##importing packages
install.packages("tidyverse")
install.packages("reshape2")
install.packages("imputeTS")
install.packages("ROCR") package for ROC curve
install.packages("caret")
install.packages("verification")
library(ggplot2)
library(reshape2)
library(imputeTS)  ##for mean imputation
library(caTools)    ##package for train test split
library(dplyr)
library(InformationValue)
library(ROCR)
library(caret)
library(verification)
##importing dataset 
df=read.csv(file.choose())

head(df)


##basic statistical informations
str(df)
summary(df)
dim(df)

##looking for correlations using heatmap 
cor(df)   ##computed correlation matrix 
corr_mat=round(cor(df),2)  ##rounded to 2 decimel

# reduce the size of correlation matrix
melted_corr_mat <- melt(corr_mat)
 
# plotting the correlation heatmap with annotations

ggplot(data = melted_corr_mat, aes(x=Var1, y=Var2,
                                   fill=value)) + 
geom_tile()+
geom_text(aes(Var2, Var1, label = value), 
          color = "black", size = 4)

##looking for missing values or duplicates
sum(is.na(df$Pregnancies))
sum(is.na(df$Glucose))
sum(is.na(df$BloodPressure))
sum(is.na(df$SkinThickness))
sum(is.na(df$Insulin))
sum(is.na(df$BMI))
sum(is.na(df$Age))
sum(is.na(df$Outcome))
###so the data has no missing values
##checking outliers using scatterlot
plot(df$Glucose)
plot(df$BloodPressure)
plot(df$SkinThickness)
plot(df$Insulin)
plot(df$BMI)

##it is observed that the above features have many outliers and the outliers are zero values
###check for summary of data frame
summary(df)
colSums(df==0)  ##checking the number of zeros in each features

#replacing the zeros by imputing mean in each of the important features
df$Glucose[df$Glucose==0]<-NA
df$BloodPressure[df$BloodPressure==0]<-NA
df$SkinThickness[df$SkinThickness==0]<-NA
df$Insulin[df$Insulin==0]<-NA
df$BMI[df$BMI==0]<-NA

df$Glucose<-round(na_mean(df$Glucose, option = "mean", maxgap = Inf),0)##this is only for mean imputation
df$BloodPressure<-round(na_mean(df$BloodPressure, option = "mean", maxgap = Inf),0)##this is only for mean imputation
df$SkinThickness<-round(na_mean(df$SkinThickness, option = "mean", maxgap = Inf),0)##this is only for mean imputation
df$Insulin<-round(na_mean(df$Insulin, option = "mean", maxgap = Inf),0)##this is only for mean imputation
df$BMI<-round(na_mean(df$BMI, option = "mean", maxgap = Inf),1)##this is only for mean imputation

###logistic reression model
##split features and target 
X=df[-8]          ##features
y=df[8]		##target
##splitting the data into trainning and test data

set.seed(1)
sample <- sample.split(df, SplitRatio = 0.8)
train_df  <- subset(df, sample == TRUE)
test_df   <- subset(df, sample == FALSE)

##spliting the data set into outcome and features
train_X=train_df[-8]
train_y=train_df[8]
test_X=test_df[-8]
test_y=test_df[8]

#checking the dimensions  
dim(train_y)
dim(test_y)
dim(train_X)
dim(test_X)
head(train_X)
head(train_df)
##feature scaling
a<- train_df %>% mutate_all(~(scale(.) %>% as.vector))
b<- test_df %>% mutate_all(~(scale(.) %>% as.vector))

###Model training
logit_model<- glm( Outcome ~  Age+BMI+ Insulin+SkinThickness+BloodPressure+Glucose+Pregnancies,
                    data = train_df,
                    family = "binomial")

summary(logit_model)
###model testing

predict_model <- predict(logit_model,
                       test_df, type = "response")

###predicting with input values
x<-data.frame(Pregnancies = 17,Glucose = 195 ,BloodPressure = 122 , SkinThickness = 99 ,Insulin = 846,BMI = 67,Age = 81  )
predict_model <- predict(logit_model,
                       x, type = "response")
predict_model

###model performance

q<-ifelse(predict_model<=0.5, 0, 1)   ###assuming 0.5 as the optimal threshold probability
q
is.factor(q)
is.factor(test_df$Outcome)

confusionMatrix(test_df$Outcome,q )

##plot the ROC curve
roc.plot(test_df$Outcome, q)
#ROC-curve using pROC library
library(pROC)
roc_score=roc(test_df$Outcome, q) #AUC score
plot(roc_score ,main ="ROC curve -- Logistic Regression ")


