#============================================================# Load cleaned data 

news_pop_rf <- read.csv('Newspop_cleaned.csv')
str(news_pop_rf)

#============================================================# Load required packages

library(reshape2)
library(DAAG)
library(e1071)
library(lattice)
library(pROC)
library(randomForest)
library(heuristica)
library(caret)
library(ROSE)

#============================================================# Log transformation for target variable

news_pop_rf$normshares <- log(news_pop_rf$shares)

boxplot(news_pop_rf$normshares, names = 'Number of shares', 
        main = 'Boxplot for Number of shares', 
        ylab = 'Number of shares', 
        sub = 'After log transformation')
boxplotstats<-boxplot(news_pop_rf$normshares)$stats

#Returns a vector in length 5, containes the extreme value of lower whisker, lower hinge, median, upper hinge, upper whisker
print(boxplotstats)

#Assign values into variables for easier calling in subsquent analyses

min_share <- boxplotstats [1,1]
low_hinge <- boxplotstats [2,1]
median_share <- boxplotstats [3,1]
up_hinge <- boxplotstats [4,1]
max_share <- boxplotstats [5,1]

spread<-up_hinge-low_hinge
low_fence<-low_hinge-3*spread #3 Standard deviation below from lower hinge
upfence<-up_hinge+3*spread #3 standard deviation above from upper hinge
print(spread)
print(low_fence)
print(upfence)

#============================================================# Divide target variable (shares) into categorical variable

#Two categories (Popular/Not_popular)
news_pop_rf$popularity <-cut(news_pop_rf$normshares,c(low_fence,median_share,upfence),labels=c("Not_Popular","Popular"))
table(news_pop_rf$popularity)

#Label encoding for target variable
news_pop_rf$popularity <- ifelse(news_pop_rf$popularity == "Popular", news_pop_rf$popularity <- 1, news_pop_rf$popularity <- 0)
table(news_pop_rf$popularity)
news_pop_rf$popularity <- as.factor(news_pop_rf$popularity)

#============================================================# Factorize variable

str(news_pop_rf)

# Making variable into factor
news_pop_rf = news_pop_rf[, -1] # Remove x
news_pop_rf$data_channel_is_lifestyle <- as.factor(news_pop_rf$data_channel_is_lifestyle)
news_pop_rf$data_channel_is_entertainment <- as.factor(news_pop_rf$data_channel_is_entertainment)
news_pop_rf$data_channel_is_bus <- as.factor(news_pop_rf$data_channel_is_bus)
news_pop_rf$data_channel_is_socmed <- as.factor(news_pop_rf$data_channel_is_socmed)
news_pop_rf$data_channel_is_tech <- as.factor(news_pop_rf$data_channel_is_tech)
news_pop_rf$data_channel_is_world <- as.factor(news_pop_rf$data_channel_is_world)
news_pop_rf$weekday_is_monday <- as.factor(news_pop_rf$weekday_is_monday)
news_pop_rf$weekday_is_tuesday <- as.factor(news_pop_rf$weekday_is_tuesday)
news_pop_rf$weekday_is_wednesday <- as.factor(news_pop_rf$weekday_is_wednesday)
news_pop_rf$weekday_is_thursday <- as.factor(news_pop_rf$weekday_is_thursday)
news_pop_rf$weekday_is_friday <- as.factor(news_pop_rf$weekday_is_friday)
news_pop_rf$weekday_is_saturday <- as.factor(news_pop_rf$weekday_is_saturday)
news_pop_rf$weekday_is_sunday <- as.factor(news_pop_rf$weekday_is_sunday)

str(news_pop_rf)

#============================================================# Divide data into training and testing set

ind_rf <- sample(nrow(news_pop_rf), 0.7 * nrow(news_pop_rf))
train_rf <- news_pop_rf[ind_rf, ]
test_rf <- news_pop_rf[-ind_rf, ]
table(train_rf$popularity)
table(test_rf$popularity)
table(news_pop_rf$popularity)

# Equal size
prop.table(table(news_pop_rf$popularity))
prop.table(table(train_rf$popularity))
prop.table(table(test_rf$popularity))

#============================================================# Define selected variable

input_var_rf <- c("popularity", 
              "kw_avg_avg",
              "kw_max_avg",
              "self_reference_avg_sharess",
              "n_tokens_content",
              "n_non_stop_words",
              "num_imgs",
              "num_hrefs",
              "n_unique_tokens",
              "LDA_00",
              "LDA_01",
              "LDA_02",
              "LDA_03",
              "LDA_04",
              "data_channel_is_entertainment",
              "data_channel_is_tech",
              "data_channel_is_socmed",
              "n_non_stop_unique_tokens",
              "global_subjectivity",
              "global_sentiment_polarity",
              "average_token_length",
              "rate_positive_words",
              "rate_negative_words",
              "global_rate_positive_words",
              "global_rate_negative_words")

#============================================================# Training model

# Basic Random Forest with selected variable                                           Experiment 1

#============================================================# 

set.seed(66)
rf_model_1 = randomForest(x = train_rf[, (input_var_rf)][,-1], y = train_rf$popularity, 
                          ntree=500)
rf_model_1

# predict on training set                                                                        1)
rf_pred_train <- predict(rf_model_1, train_rf[, (input_var_rf)][, -1])
cm_train_rf <- table(rf_pred_train, train_rf$popularity)
confusionMatrix(cm_train_rf)
roc.curve(rf_pred_train, train_rf$popularity)

# predict on testing set                                                                         2)
rf_pred_test <- predict(rf_model_1, test_rf[, (input_var_rf)][, -1])
cm_test_rf <- table(rf_pred_test, test_rf$popularity)
confusionMatrix(cm_test_rf)
roc.curve(rf_pred_test, test_rf$popularity)

#============================================================# Training model

# Random Forest Tuning by tools                                                        Experiment 2

#============================================================# 

optimal_mtry <-tuneRF(train_rf[, (input_var_rf)][, -1], train_rf$popularity,
       stepFactor=1.5,
       plot = TRUE,
       ntreeTry = 400,
       trace = TRUE,
       improve = 0.01)

optimal_mtry

best_mtry <- optimal_mtry[optimal_mtry[,2] == min(optimal_mtry[, 2]), 1]
best_mtry # returning optimal mtry

set.seed(66)
rf <- randomForest(popularity~.,data = train_rf[, (input_var_rf)],
                   mtry = best_mtry, 
                   importance = TRUE, 
                   ntree = 500)
print(rf)
importance(rf)
varImpPlot(rf)

# predict on training set                                                                        1)
pred_train = predict(rf, train_rf[, (input_var_rf)])
cm_pred = table(pred_train, train_rf$popularity)
confusionMatrix(cm_pred)
roc.curve(pred_train, train_rf$popularity)

# predict on testing set                                                                        2)
pred_test = predict(rf, test_rf[, (input_var_rf)])
cm_pred_test = table(pred_test, test_rf$popularity)
confusionMatrix(cm_pred_test)
roc.curve(pred_test, test_rf$popularity)



#============================================================# Training model

# Random Forest with k fold cross validation where K = 5                                  Experiment 3

#============================================================# 

library(caret)
library(e1071)
library(rpart)

noOfFolds <- trainControl(method = "cv", number = 5) # where k = 5
grid = expand.grid(.cp = seq(0.01, 0.5, 0.01))

rf_model_kFold_3 = train(popularity ~., data = train_rf[, (input_var_rf)], method = "rpart", trControl = noOfFolds, tuneGrid = grid )
rf_model_kFold_3 # getting final cp
plot(rf_model_kFold_3)

# Building with optimal cp on training set
library(rpart.plot)
rf_kFold_classifier <- rpart(popularity ~., data = train_rf[, (input_var_rf)], method = "class", cp = 0.01 )
plotcp(rf_kFold_classifier)

# predict on training set                                                                        1)
rp_pred_train <- predict(rf_kFold_classifier, data = train_rf[, (input_var_rf)][, -1], type = "class")
cm_pred_train <- table(rp_pred_train, train_rf$popularity)
confusionMatrix(cm_pred_train)
roc.curve(rp_pred_train, train_rf$popularity)


# predict on testing set                                                                         2)
# Building with optimal cp on testing set
library(rpart.plot)
rf_kFold_classifier_test <- rpart(popularity ~., data = test_rf[, (input_var_rf)], method = "class", cp = 0.01 )
plotcp(rf_kFold_classifier_test)

# predict on training set                                                                        1)
rp_pred_test <- predict(rf_kFold_classifier_test, data = test_rf[, (input_var_rf)][, -1], type = "class")
cm_pred_test <- table(rp_pred_test, test_rf$popularity)
confusionMatrix(cm_pred_test)
roc.curve(rp_pred_test, test_rf$popularity)
