#============================================================# Load cleaned data 

news_pop_svm <- read.csv('Newspop_cleaned.csv', stringsAsFactors = TRUE)

str(news_pop_pred)

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
library(kernlab) # Linear Svm

#============================================================# Log transformation for target variable

news_pop_svm$normshares <- log(news_pop_svm$shares)

boxplot(news_pop_svm$normshares, names = 'Number of shares', 
        main = 'Boxplot for Number of shares', 
        ylab = 'Number of shares', 
        sub = 'After log transformation')
boxplotstats<-boxplot(news_pop_svm$normshares)$stats

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
news_pop_svm$popularity <-cut(news_pop_svm$normshares,c(low_fence,median_share,upfence),labels=c("Not_Popular","Popular"))
table(news_pop_svm$popularity)

#Label encoding for target variable
news_pop_svm$popularity <- ifelse(news_pop_svm$popularity == "Popular", news_pop_svm$popularity <- 1, news_pop_svm$popularity <- 0)
table(news_pop_svm$popularity)

#Convert variables into factors
news_pop_svm$data_channel_is_bus <- as.factor(news_pop_svm$data_channel_is_bus)
news_pop_svm$data_channel_is_entertainment <- as.factor(news_pop_svm$data_channel_is_entertainment)
news_pop_svm$data_channel_is_lifestyle <- as.factor(news_pop_svm$data_channel_is_lifestyle)
news_pop_svm$data_channel_is_socmed <- as.factor(news_pop_svm$data_channel_is_socmed)
news_pop_svm$data_channel_is_tech <- as.factor(news_pop_svm$data_channel_is_tech)
news_pop_svm$data_channel_is_world <- as.factor(news_pop_svm$data_channel_is_world)
news_pop_svm$weekday_is_monday <- as.factor(news_pop_svm$weekday_is_monday)
news_pop_svm$weekday_is_tuesday <- as.factor(news_pop_svm$weekday_is_tuesday)
news_pop_svm$weekday_is_wednesday <- as.factor(news_pop_svm$weekday_is_wednesday)
news_pop_svm$weekday_is_thursday <- as.factor(news_pop_svm$weekday_is_thursday)
news_pop_svm$weekday_is_friday <- as.factor(news_pop_svm$weekday_is_friday)
news_pop_svm$weekday_is_saturday <- as.factor(news_pop_svm$weekday_is_saturday)
news_pop_svm$weekday_is_sunday <- as.factor(news_pop_svm$weekday_is_sunday)

#============================================================# Divide data into training and testing set

ind_svm <- sample(nrow(news_pop_svm), 0.7*nrow(news_pop_svm))
train_svm <- news_pop_svm[ind_svm, ]
test_svm <- news_pop_svm[-ind_svm, ]
table(train_svm$popularity)
table(test_svm$popularity)
table(news_pop_svm$popularity)

# Equal size
prop.table(table(news_pop_svm$popularity))
prop.table(table(train_svm$popularity))
prop.table(table(test_svm$popularity))

#============================================================# Training model

# Basic Support Vector Machine ( Linear ) with all variables                                              Experiment 1

#============================================================# 

# Experiment 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Linear SVM
svm_model_1 <- ksvm(popularity ~., data = train_svm, kernel = "vanilladot")
svm_model_1 # Basic Support Vector Machine ( Linear ) with all variables 

set.seed(123)
# predict train set - fitting classifier into training set                       1)
svm_pred_train <- predict(svm_model_1, train_svm)
svm_prd_bin <- ifelse(svm_pred_train > 0.5, 1, 0)
svm_cm <- table(svm_prd_bin, train_svm$popularity)
confusionMatrix(svm_cm)
roc.curve(svm_prd_bin, train_svm$popularity)

set.seed(661)
# predict train set - fitting classifier into testing set                        2)
svm_pred_test <- predict(svm_model_1, test_svm)
svm_pred_bin <- ifelse(svm_pred_test > 0.5, 1, 0)
svm_cm <- table(svm_pred_bin, test_svm$popularity)
svm_cm
confusionMatrix(svm_cm)
roc.curve(svm_pred_bin, test_svm$popularity)

 #============================================================# Training model

# Basic Support Vector Machine ( Polynomial ) with all variables                                          Experiment 2

#============================================================# 

# Experiment 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Polynomial SVM
svm_model_polydot <- ksvm(popularity ~., data = train_svm, kernel = "polydot")
svm_model_polydot # Basic Support Vector Machine ( Polynomial ) with all variables 

# predict train set - fitting classifier into training set                       1)
svm_pred_train <- predict(svm_model_polydot, train_svm)
svm_pred_bin <- ifelse(svm_pred_train > 0.5, 1, 0)
svm_cm <- table(svm_pred_bin, train_svm$popularity)
confusionMatrix(svm_cm)
roc.curve(svm_pred_bin, train_svm$popularity)

# predict train set - fitting classifier into testing set                        2)
svm_pred_test <- predict(svm_model_polydot, test_svm)
svm_pred_bin_test <- ifelse(svm_pred_test > 0.5, 1, 0)
svm_cm <- table(svm_pred_bin_test, test_svm$popularity)
confusionMatrix(svm_cm)
roc.curve(svm_pred_bin_test, test_svm$popularity)


#============================================================# Training model

# Basic Support Vector Machine ( Radial ) with all variables                                              Experiment 3

#============================================================# 

# Experiment 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Radial SVM
svm_model_rbf <- ksvm(popularity ~., data = train_svm, kernel = "rbfdot")
svm_model_rbf # Basic Support Vector Machine ( Radial ) with all variables 

# predict train set - fitting classifier into training set                       1)
svm_pred_train <- predict(svm_model_rbf, train_svm)
svm_pred_bin_train <- ifelse(svm_pred_train > 0.5, 1, 0)
svm_cm <- table(train_svm$popularity, svm_pred_bin_train)
confusionMatrix(svm_cm)
roc.curve(train_svm$popularity, svm_pred_bin_train)

# predict train set - fitting classifier into testing set                        2)
svm_pred_test <- predict(svm_model_rbf, test_svm)
svm_pred_bin_test <- ifelse(svm_pred_test > 0.5, 1, 0)
svm_cm <- table(test_svm$popularity, svm_pred_bin_test)
confusionMatrix(svm_cm)
roc.curve(test_svm$popularity, svm_pred_bin_test)

#============================================================# Training model

# Basic Support Vector Machine ( Linear ) with selected variables                                              Experiment 4

#============================================================# 

# Selected variable
input_var_svm <- "popularity~kw_avg_avg+
               self_reference_min_shares+
               kw_max_avg+
               self_reference_avg_sharess+
               LDA_00+
               X+
               n_unique_tokens+
               kw_min_avg+
               LDA_02+
               n_tokens_content+
               n_non_stop_words+
               weekday_is_saturday+
               LDA_04+
               data_channel_is_entertainment+
               LDA_01+
               data_channel_is_socmed+
               self_reference_max_shares+
               kw_avg_max+
               n_non_stop_unique_tokens+
               LDA_03+
               kw_avg_min+
               num_imgs+
               rate_positive_words+
               num_hrefs+
               global_sentiment_polarity+
               average_token_length+
               global_rate_positive_words+
               global_subjectivity+
               rate_negative_words+
               global_rate_negative_words"

# Experiment 4 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Linear SVM
svm_model_linear <- ksvm(as.formula(input_var_svm), data = train_svm, kernel = "vanilladot")
svm_model_linear # Basic Support Vector Machine ( Linear ) with selected variables          

# predict train set - fitting classifier into training set                       1)
svm_pred_train <- predict(svm_model_linear, train_svm, type = "response")
svm_pred_train_bin <- ifelse(svm_pred_train > 0.5, 1, 0)
svm_linear_cm <- table(svm_pred_train_bin, train_svm$popularity)
confusionMatrix(svm_linear_cm)
roc.curve(svm_pred_train_bin, train_svm$popularity)

# predict train set - fitting classifier into testing set                        2)
svm_pred_test <- predict(svm_model_linear, test_svm, type="response")
svm_pred_test_bin <- ifelse(svm_pred_test > 0.5, 1, 0)
svm_linear_cm <- table(svm_pred_test_bin, test_svm$popularity)
confusionMatrix(svm_linear_cm)
roc.curve(svm_pred_test_bin, test_svm$popularity)

#============================================================# Training model

# Basic Support Vector Machine ( Polynomial ) with selected variables                                          Experiment 5

#============================================================# 

# Experiment 5 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Polynomial SVM
svm_model_poly <- ksvm(as.formula(input_var_svm), data = train_svm, kernel = "polydot")
svm_model_poly # Basic Support Vector Machine ( Polynomial ) with selected variables - Experiment 5

# predict train set - fitting classifier into training set                       1)
svm_pred_train <- predict(svm_model_poly, train_svm, type = "response")
svm_pred_train_bin <- ifelse(svm_pred_train > 0.5, 1, 0)
svm_poly_cm <- table(svm_pred_train_bin, train_svm$popularity)
confusionMatrix(svm_poly_cm)
roc.curve(svm_pred_train_bin, train_svm$popularity)

# predict train set - fitting classifier into testing set                       2)
svm_pred_test <- predict(svm_model_poly, test_svm, type="response")
svm_pred_test_bin <- ifelse(svm_pred_test > 0.5, 1, 0)
svm_poly_test_cm <- table(svm_pred_test_bin, test_svm$popularity)
confusionMatrix(svm_poly_test_cm)
roc.curve(svm_pred_test_bin, test_svm$popularity)

#============================================================# Training model

# Basic Support Vector Machine ( Radial ) with selected variables                                              Experiment 6

#============================================================# 

# Experiment 6 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Radial SVM
svm_pop_7 <- ksvm(as.formula(input_var_svm), data = train_svm, kernel = "rbfdot")
svm_pop_7

# predict train set - fitting classifier into training set                       1)
svm_pred_train <- predict(svm_pop_7, train_svm, type = "response")
svm_pred_train_probabilities <- ifelse(svm_pred_train > 0.5, 1, 0)
svm_radial_cm <- table(svm_pred_train_probabilities, train_svm$popularity)
confusionMatrix(svm_radial_cm)
roc.curve(svm_pred_train_probabilities, train_svm$popularity)

# predict train set - fitting classifier into testing set                        2)
svm_pred_test <- predict(svm_pop_7, test_svm, type="response")
svm_pred_test_probabilities <- ifelse(svm_pred_test > 0.5, 1, 0)
svm_radial_test_cm <- table(svm_pred_test_probabilities, test_svm$popularity)
confusionMatrix(svm_radial_test_cm)
roc.curve(svm_pred_test_probabilities, test_svm$popularity)

#============================================================# 
