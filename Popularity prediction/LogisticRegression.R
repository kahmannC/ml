#============================================================# Load cleaned data 

news_pop_pred <- read.csv('Newspop_cleaned.csv')
str(news_pop_pred)

#============================================================# Load required packages

library(ggplot2)
library(reshape2)
library(DAAG)
library(e1071)
library(lattice)
library(caret)
library(pROC)
library(randomForest)
library(heuristica)

#============================================================# Log transformation for target variable

news_pop_pred$normshares <- log(news_pop_pred$shares)

boxplot(news_pop_pred$normshares, names = 'Number of shares', 
        main = 'Boxplot for Number of shares', 
        ylab = 'Number of shares', 
        sub = 'After log transformation')
boxplotstats<-boxplot(news_pop_pred$normshares)$stats

#Returns a vector in length 5, containes the extreme value of lower whisker, lower hinge, median, upper hinge, upper whisker
print(boxplotstats)

#Assign values into variables for easier calling in subsquent analyses

min_share <- boxplotstats [1,1]
low_hinge <- boxplotstats [2,1]
median_share <- boxplotstats [3,1]
up_hinge <- boxplotstats [4,1]
max_share <- boxplotstats [5,1]

spread <- up_hinge-low_hinge
low_fence <- low_hinge-3*spread # 3 Standard deviation below from lower hinge
upfence <- up_hinge + 3 * spread # 3 standard deviation above from upper hinge
print(spread)
print(low_fence)
print(upfence)

#============================================================# Divide target variable (shares) into categorical variable

#Two categories (Popular/Not_popular)
news_pop_pred$popularity <- cut(news_pop_pred$normshares,c(low_fence,median_share,upfence),labels=c("Not_Popular","Popular"))
table(news_pop_pred$popularity)

#Label encoding for target variable ~ popularity
news_pop_pred$popularity <- ifelse(news_pop_pred$popularity == "Popular", news_pop_pred$popularity <- 1, news_pop_pred$popularity <- 0)
table(news_pop_pred$popularity)

#============================================================# Split news_pop_pred into training and testing data before scaling

ind <- sample(nrow(news_pop_pred), 0.7 * nrow(news_pop_pred))
train_pop <- news_pop_pred[ind, ]
test_pop <- news_pop_pred[-ind, ]
table(train_pop$popularity)
table(test_pop$popularity)

# Equal size
prop.table(table(news_pop_pred$popularity))
prop.table(table(train_pop$popularity))
prop.table(table(test_pop$popularity))

#============================================================# Split news_pop_scale into training and testing data - after feature scaling
news_pop_scale <- news_pop_pred # Replicate dataset for feature scaling

# Define scaling function
scaling <- function(x) {
  return((x-min(x))/(max(x)-min(x)))
}

#Log transformation for shares
news_pop_scale$normshares <- log(news_pop_scale$shares)

# Feature scaling
news_pop_scale$n_tokens_title <- scaling(news_pop_scale$n_tokens_title)
news_pop_scale$n_tokens_content <- scaling(news_pop_scale$n_tokens_content)
news_pop_scale$num_hrefs <- scaling(news_pop_scale$num_hrefs)
news_pop_scale$num_self_hrefs <- scaling(news_pop_scale$num_self_hrefs)
news_pop_scale$num_imgs <- scaling(news_pop_scale$num_imgs)
news_pop_scale$average_token_length <- scaling(news_pop_scale$average_token_length)
news_pop_scale$num_keywords <- scaling(news_pop_scale$num_keywords)
news_pop_scale$kw_max_min <- scaling(news_pop_scale$kw_max_min)
news_pop_scale$kw_avg_min <- scaling(news_pop_scale$kw_avg_min)
news_pop_scale$kw_max_avg <- scaling(news_pop_scale$kw_max_avg)
news_pop_scale$kw_avg_avg <- scaling(news_pop_scale$kw_avg_avg)
news_pop_scale$self_reference_min_shares <- scaling(news_pop_scale$self_reference_min_shares)
news_pop_scale$self_reference_max_shares <- scaling(news_pop_scale$self_reference_max_shares)
news_pop_scale$self_reference_avg_sharess <- scaling(news_pop_scale$self_reference_avg_sharess)

# news_pop_scale$popularity <- ifelse(news_pop_scale$popularity == "Popular", news_pop_scale$popularity <- 1, news_pop_pred$popularity <- 0)
table(news_pop_scale$popularity)
news_pop_scale <- news_pop_scale[,-1] # remove ID

#============================================================# Split news_pop_scale into training and testing data after scaling

#Divide data into train and test set
ind_scale <- sample(nrow(news_pop_scale), 0.7 * nrow(news_pop_scale))
train_pop_scale <- news_pop_scale[ind_scale, ]
test_pop_scale <- news_pop_scale[-ind_scale, ]
table(train_pop_scale$popularity)
table(test_pop_scale$popularity)

# Equal size
prop.table(table(news_pop_scale$popularity))
prop.table(table(train_pop_scale$popularity))
prop.table(table(test_pop_scale$popularity))


#============================================================# Logistic Regression  before scaling

# Basic Logistic Regression before scaling                                              Experiment 1A

#============================================================# 

logit_model <- glm('popularity ~. -shares -normshares', family = 'binomial', data = train_pop)

# predict train set - fitting classifier into training set                       1)

logit_train <- predict(logit_model, train_pop, type = 'response')
predict_train_bin <- ifelse(logit_train > 0.5, 1, 0)
table(train_pop$popularity)
table(predict_train_bin)
cm_train = table(train_pop$popularity, predict_train_bin)
confusionMatrix(table(train_pop$popularity, predict_train_bin))
log_roc_train <- roc(predict_train_bin, train_pop$popularity)
print(log_roc_train)
plot(log_roc_train) #Plot ROC curve

# predict test set - fitting classifier into testing set                         2)
log_pred <- predict(logit_model, test_pop, type = 'response')
predict_bin <- ifelse(log_pred > 0.5, 1, 0)
table(test_pop$popularity)
table(predict_bin)
cm = table(test_pop$popularity, predict_bin)
confusionMatrix(table(test_pop$popularity, predict_bin))
log_roc_train <- roc(predict_train_bin, test_pop$popularity)
print(log_roc_train)
plot(log_roc_train) #Plot ROC curve

#============================================================# Basic Logistic Regression after feature scaling

# Basic Logistic Regression after feature scaling                                              Experiment 2A                                   

#============================================================# 

logit_model_scale <- glm('popularity ~. -shares -normshares', family = 'binomial', data = train_pop_scale)

# predict train set - fitting classifier into training set                       1)

logit_train_scale <- predict(logit_model_scale, train_pop_scale, type = 'response')
predict_train_bin <- ifelse(logit_train_scale > 0.5, 1, 0)
table(train_pop$popularity)
table(predict_train_bin)
cm_train_scale = table(train_pop_scale$popularity, predict_train_bin)
confusionMatrix(table(train_pop_scale$popularity, predict_train_bin))
log_roc_train <- roc(predict_train_bin, train_pop_scale$popularity)
print(log_roc_train)
plot(log_roc_train) #Plot ROC curve

# predict test set - fitting classifier into testing set                         2)

log_pred_scale <- predict(logit_model_scale, test_pop_scale, type = 'response')
predict_test_bin <- ifelse(log_pred_scale > 0.5, 1, 0)
table(test_pop_scale$popularity)
table(predict_test_bin)
cm = table(test_pop_scale$popularity, predict_test_bin)
confusionMatrix(table(test_pop_scale$popularity, predict_test_bin))
log_roc_test <- roc(predict_test_bin, test_pop_scale$popularity)
print(log_roc_test)
plot(log_roc_test) #Plot ROC curve

#============================================================#

#Building Lasso logistic regression model before feature scaling                                              Experiment 3A

#============================================================#

library(tidyverse)
library(caret)
library(glmnet)
library(ROSE)
library(caret)

table(train_pop$popularity)
x2 <- model.matrix(popularity ~.,train_pop)[, -61]
y2 <- train_pop$popularity
lambdas_to_try <- 10^seq(-3, 5, length.out = 100)
grid = 10^seq(10, -2, length = 100)

cv.lasso <- cv.glmnet(x2, y2, alpha = 1, lambda = lambdas_to_try, standardize = TRUE, nfolds = 15)
plot(cv.lasso)

# assign lambda = cv.lasso$lambda.min that produce highest accuracy
model <- glmnet(x2, y2, alpha = 1, standardize = TRUE, lambda = cv.lasso$lambda.min)

# model coefficiency
coef(model)

# predict train set - fitting classifier into training set                      1)

x2_train <- model.matrix(popularity ~.,train_pop)[, -61] # Removing target variable before building the model
probabilities <- model %>% predict(newx = x2_train)

y_hat_cv <- predict(model, x2_train)

predicted.classes <- ifelse(probabilities > 0.5, 1, 0)
observed.classes <- train_pop$popularity
mean(predicted.classes == observed.classes)
log_roc_lasso <- roc(predicted.classes, observed.classes)
print(log_roc_lasso)
roc.curve(observed.classes, predicted.classes) # Produce ROC Curve
table(observed.classes, predicted.classes)
confusionMatrix(table(observed.classes, predicted.classes)) # Produce Confusion Matrix

ssr_cv <- t(train_pop$popularity - predicted.classes) %*% (train_pop$popularity - predicted.classes)
rsq_lasso_cv <- cor(train_pop$popularity, predicted.classes)^2

res <- glmnet(x2, y2, alpha = 1, lambda = lambdas_to_try, standardize = FALSE)
plot(res, xvar = "lambda")
legend("bottomright", lwd = 1, col = 1:6, legend = colnames(x2), cex = .7)

# predict test set - fitting classifier into testing set                      2)

x2_test <- model.matrix(popularity ~.,test_pop)[, -61] # Removing target variable before building the model
probabilities <- model %>% predict(newx = x2_test)

y_hat_cv <- predict(model, x2_test)

predicted.classes <- ifelse(probabilities > 0.5, 1, 0)
observed.classes <- test_pop$popularity
mean(predicted.classes == observed.classes)
log_roc_lasso <- roc(predicted.classes, observed.classes)
print(log_roc_lasso)
roc.curve(observed.classes, predicted.classes) # Produce ROC Curve
table(observed.classes, predicted.classes)
confusionMatrix(table(observed.classes, predicted.classes)) # Produce Confusion Matrix

ssr_cv <- t(test_pop$popularity - predicted.classes) %*% (test_pop$popularity - predicted.classes)
rsq_lasso_cv <- cor(test_pop$popularity, predicted.classes)^2

res <- glmnet(x2, y2, alpha = 1, lambda = lambdas_to_try, standardize = FALSE)
plot(res, xvar = "lambda")
legend("bottomright", lwd = 1, col = 1:6, legend = colnames(x2), cex = .7)

#============================================================#

#Building  Lasso logistic regression model after feature scaling                                              Experiment 4A

#============================================================#

#Lasso regression 
#Normalized

set.seed(666)
table(train_pop_scale$popularity)
 
x_scale <- model.matrix(popularity ~.,train_pop_scale)[, -60] # Removing target variable
y_scale <- train_pop_scale$popularity
lambdas_scale <- 10^seq(-3, 5, length.out = 100)
grid_scale = 10^seq(10, -2, length = 100)

library(glmnet)

cv.lasso_scale <- cv.glmnet(x_scale, y_scale, alpha = 1, lambda = lambdas_scale, standardize = TRUE, nfolds = 15)
plot(cv.lasso)

model_scale <- glmnet(x_scale, y_scale, alpha = 1, standardize = TRUE, lambda = cv.lasso_scale$lambda.min)
coef(model) # Model coefficiency

# predict train set - fitting classifier into training set                      1)

x_train_scale <- model.matrix(popularity ~.,train_pop_scale)[, -60]
probabilities_scale <- model_scale %>% predict(newx = x_train_scale)

predicted.classes_scale <- ifelse(probabilities_scale > 0.5, 1, 0)
observed.classes_scale <- train_pop_scale$popularity
mean(predicted.classes_scale == observed.classes_scale)
log_roc_lassos <- roc(predicted.classes_scale, observed.classes_scale)
print(log_roc_lassos)
roc.curve(observed.classes_scale, predicted.classes_scale)
confusionMatrix(table(observed.classes_scale, predicted.classes_scale))

ssr_cv_scale <- t(train_pop_scale$popularity - predicted.classes_scale) %*% (train_pop_scale$popularity - predicted.classes_scale)
rsq_lasso_cvs <- cor(train_pop_scale$popularity, predicted.classes_scale)^2

res_scale <- glmnet(x_scale, y_scale, alpha = 1, lambda = lambdas_scale, standardize = FALSE)
plot(res, xvar = "lambda")
legend("bottomright", lwd = 1, col = 1:6, legend = colnames(x2), cex = .7)

# predict test set - fitting classifier into testing set                      2)

x_test_scale <- model.matrix(popularity ~.,test_pop_scale)[, -60]
probabilities_scale <- model_scale %>% predict(newx = x_test_scale)

predicted.classes_scale <- ifelse(probabilities_scale > 0.5, 1, 0)
observed.classes_scale <- test_pop_scale$popularity
mean(predicted.classes_scale == observed.classes_scale)
log_roc_lassos <- roc(predicted.classes_scale, observed.classes_scale)
print(log_roc_lassos)
roc.curve(observed.classes_scale, predicted.classes_scale)
confusionMatrix(table(observed.classes_scale, predicted.classes_scale))

ssr_cv_scale <- t(test_pop_scale$popularity - predicted.classes_scale) %*% (test_pop_scale$popularity - predicted.classes_scale)
rsq_lasso_cvs <- cor(test_pop_scale$popularity, predicted.classes_scale)^2

res_scale <- glmnet(x_scale, y_scale, alpha = 1, lambda = lambdas_scale, standardize = FALSE)
plot(res, xvar = "lambda")
legend("bottomright", lwd = 1, col = 1:6, legend = colnames(x2), cex = .7)

#============================================================#

#Building Ridge logistic regression model before feature scaling                                              Experiment 5A

#============================================================#

set.seed(123)    # seef for reproducibility
library(glmnet)  # for ridge regression
library(dplyr)   # for data cleaning
library(psych)   # for function tr() to compute trace of a matrix

x3 <- model.matrix(popularity ~.,train_pop)[, -61]
y3 <- train_pop$popularity
lambdas_to_try <- 10^seq(-3, 5, length.out = 100)
ridge_cv <- cv.glmnet(x3, y3, alpha = 0, lambda = lambdas_to_try,
                      standardize = TRUE, nfolds = 10)
plot(ridge_cv)

lambda_cv <- ridge_cv$lambda.min
model_cv <- glmnet(x3, y3, alpha = 0, lambda = lambda_cv, standardize = TRUE)

# predict train set - fitting classifier into training set                      1)

x3_train <- model.matrix(popularity ~.,train_pop)[, -61]
y3_train <- train_pop$popularity

# Fitting classifier into testing set
y_hat_cv <- predict(model_cv, x3_train)

predicted.classes_ridge <- ifelse(y_hat_cv > 0.5, 1, 0)

mean(predicted.classes_ridge == y3_train)
cm_ridge = table(y3_train, predicted.classes_ridge)
cm_ridge
roc.curve(y3_train, predicted.classes_ridge) # Plotting roc curve
confusionMatrix(cm_ridge)

# Fit final model, get its sum of squared residuals and multiple R-squared
ssr_cv <- t(y3_train - y_hat_cv) %*% (y3_train - y_hat_cv)
rsq_ridge_cv <- cor(y3_train, y_hat_cv)^2
ssr_cv
rsq_ridge_cv

# predict test set - fitting classifier into testing set                       2)

x3_test <- model.matrix(popularity ~.,test_pop)[, -61]
y3_test <- test_pop$popularity

# Fitting classifier into testing set
y_hat_cv <- predict(model_cv, x3_test)

predicted.classes_ridge <- ifelse(y_hat_cv > 0.5, 1, 0)

mean(predicted.classes_ridge == y3_test)
cm_ridge = table(y3_test, predicted.classes_ridge)
cm_ridge
roc.curve(y3_test, predicted.classes_ridge) # Plotting roc curve
confusionMatrix(cm_ridge)

# Fit final model, get its sum of squared residuals and multiple R-squared
ssr_cv <- t(y3_test - y_hat_cv) %*% (y3_test - y_hat_cv)
rsq_ridge_cv <- cor(y3_test, y_hat_cv)^2
ssr_cv
rsq_ridge_cv


#============================================================#

#Building Ridge logistic regression model after feature scaling                                              Experiment 6A

#============================================================#

set.seed(123)    # seef for reproducibility
library(glmnet)  # for ridge regression
library(dplyr)   # for data cleaning
library(psych)   # for function tr() to compute trace of a matrix

x_scale <- model.matrix(popularity ~.,train_pop_scale)[, -60]
y_scale <- train_pop_scale$popularity
lambdas_to_try <- 10^seq(-3, 5, length.out = 100)
ridge_scale <- cv.glmnet(x_scale, y_scale, alpha = 0, lambda = lambdas_to_try,
                         standardize = TRUE, nfolds = 10)
plot(ridge_scale)

lambda_scale <- ridge_scale$lambda.min
model_scale <- glmnet(x_scale, y_scale, alpha = 0, lambda = lambda_scale, standardize = TRUE)

# predict train set - fitting classifier into training set                      1)

x_scale_train <- model.matrix(popularity ~.,train_pop_scale)[, -60]
y_scale_train <- train_pop_scale$popularity

# Fitting classifier into training set
y_hat_cv <- predict(model_scale, x_scale_train)

predicted.classes_ridge <- ifelse(y_hat_cv > 0.5, 1, 0)

mean(predicted.classes_ridge == y_scale_train)
cm_ridge = table(y_scale_train, predicted.classes_ridge)
cm_ridge
roc.curve(y_scale_train, predicted.classes_ridge) # Plotting roc curve
confusionMatrix(cm_ridge)

# Fit final model, get its sum of squared residuals and multiple R-squared
ssr_cv <- t(y_scale_train - y_hat_cv) %*% (y_scale_train - y_hat_cv)
rsq_ridge_cv <- cor(y_scale_train, y_hat_cv)^2
ssr_cv
rsq_ridge_cv

# predict test set - fitting classifier into testing set                      2)

x_scale_test <- model.matrix(popularity ~.,test_pop_scale)[, -60]
y_scale_test <- test_pop_scale$popularity

# Fitting classifier into testing set
y_hat_cv <- predict(model_scale, x_scale_test)

predicted.classes_ridge <- ifelse(y_hat_cv > 0.5, 1, 0)

mean(predicted.classes_ridge == y_scale_test)
cm_ridge = table(y_scale_test, predicted.classes_ridge)
cm_ridge
roc.curve(y_scale_test, predicted.classes_ridge) # Plotting roc curve
confusionMatrix(cm_ridge)

# Fit final model, get its sum of squared residuals and multiple R-squared
ssr_cv <- t(y_scale_test - y_hat_cv) %*% (y_scale_test - y_hat_cv)
rsq_ridge_cv <- cor(y_scale_test, y_hat_cv)^2
ssr_cv
rsq_ridge_cv

