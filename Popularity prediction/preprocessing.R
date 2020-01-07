news_pop <- read.csv('Online news popularity.csv', header = T, stringsAsFactors = FALSE)
library(scales)
str(news_pop)

summary(news_pop) 

#missing values checking
sum(is.na(news_pop))
#There are no missing values

#=============================================#
#Normality treatment for num_hrefs
news_pop2 <- news_pop

t1 <- describe(news_pop2$num_hrefs)
boxplot(news_pop2$num_hrefs)
news_pop2$num_hrefs <- squish(news_pop2$num_hrefs, round(quantile(news_pop2$num_hrefs, c(.05, .95))))
s1 <- describe(news_pop2$num_hrefs)
boxplot(news_pop2$num_hrefs)

#Normality treatment for num_self_hrefs
t2 <- describe(news_pop2$num_self_hrefs)
boxplot(news_pop2$num_self_hrefs)
s2 <- news_pop2$num_self_hrefs <- squish(news_pop2$num_self_hrefs, round(quantile(news_pop2$num_self_hrefs, c(.05, .95))))
describe(news_pop2$num_self_hrefs)
boxplot(news_pop2$num_self_hrefs)

#Normality treatment for num_img
t3 <- describe(news_pop2$num_imgs)
news_pop2$num_imgs
news_pop2$num_imgs <- squish(news_pop2$num_imgs, round(quantile(news_pop2$num_imgs, c(.05, .95))))
s3 <- describe(news_pop2$num_img)
boxplot(news_pop2$num_img)

#Normality treatment for num_videos
t4 <- describe(news_pop2$num_videos)
boxplot(news_pop2$num_videos)
news_pop2$num_videos <- squish(news_pop2$num_videos, round(quantile(news_pop2$num_videos, c(.05, .95))))
s4 <- describe(news_pop2$num_videos)
boxplot(news_pop2$num_videos)

#Normality treatment for n_nonstop_unique_tokens
describe(news_pop2$n_non_stop_unique_tokens)
boxplot(news_pop2$n_non_stop_unique_tokens)
news_pop2$n_non_stop_unique_tokens <- squish(news_pop2$n_non_stop_unique_tokens, round(quantile(news_pop2$n_non_stop_unique_tokens, c(.05, .95))))
describe(news_pop2$n_non_stop_unique_tokens)
boxplot(news_pop2$n_non_stop_unique_tokens)

#Normality treatment for average_token_length
describe(news_pop2$average_token_length)
boxplot(news_pop2$average_token_length)
news_pop2$average_token_length <- squish(news_pop2$average_token_length, round(quantile(news_pop2$average_token_length, c(.05, .95))))
describe(news_pop2$average_token_length)
boxplot(news_pop2$average_token_length)

#Normality treatment for kw_max_min
describe(news_pop2$kw_max_min)
boxplot(news_pop2$kw_max_min)
news_pop2$kw_max_min <- squish(news_pop2$kw_max_min, round(quantile(news_pop2$kw_max_min, c(.05, .95))))
describe(news_pop2$kw_max_min)
boxplot(news_pop2$kw_max_min)

#Normality treatment for kw_avg_min
describe(news_pop2$kw_avg_min)
boxplot(news_pop2$kw_avg_min)
news_pop2$kw_avg_min <- squish(news_pop2$kw_avg_min, round(quantile(news_pop2$kw_avg_min, c(.05, .95))))
describe(news_pop2$kw_avg_min)
boxplot(news_pop2$kw_avg_min)

#Normality treatment for kw_min_max
describe(news_pop2$kw_min_max)
boxplot(news_pop2$kw_min_max)
news_pop2$kw_min_max <- squish(news_pop2$kw_min_max, round(quantile(news_pop2$kw_min_max, c(.05, .95))))
describe(news_pop2$kw_min_max)
boxplot(news_pop2$kw_min_max)

#Normality treatment for kw_max_avg
describe(news_pop2$kw_max_avg)
boxplot(news_pop2$kw_max_avg)
news_pop2$kw_max_avg <- squish(news_pop2$kw_max_avg, round(quantile(news_pop2$kw_max_avg, c(.05, .95))))
describe(news_pop2$kw_max_avg)
boxplot(news_pop2$kw_max_avg)

#Normality treatment for kw_avg_avg
describe(news_pop2$kw_avg_avg)
boxplot(news_pop2$kw_avg_avg)
news_pop2$kw_avg_avg <- squish(news_pop2$kw_avg_avg, round(quantile(news_pop2$kw_avg_avg, c(.05, .95))))
describe(news_pop2$kw_avg_avg)
boxplot(news_pop2$kw_avg_avg)

#Normality treatment for self_reference_min_shares
describe(news_pop2$self_reference_min_shares)
boxplot(news_pop2$self_reference_min_shares)
news_pop2$self_reference_min_shares <- squish(news_pop2$self_reference_min_shares, round(quantile(news_pop2$self_reference_min_shares, c(.05, .95))))
describe(news_pop2$self_reference_min_shares)
boxplot(news_pop2$self_reference_min_shares)

#Normality treatment for self_reference_max_shares
describe(news_pop2$self_reference_max_shares)
boxplot(news_pop2$self_reference_max_shares)
news_pop2$self_reference_max_shares <- squish(news_pop2$self_reference_max_shares, round(quantile(news_pop2$self_reference_max_shares, c(.05, .95))))
describe(news_pop2$self_reference_max_shares)
boxplot(news_pop2$self_reference_max_shares)

#Normality treatment for self_reference_avg_shares
describe(news_pop2$self_reference_avg_sharess)
boxplot(news_pop2$self_reference_avg_sharess)
news_pop2$self_reference_avg_sharess <- squish(news_pop2$self_reference_avg_sharess, round(quantile(news_pop2$self_reference_avg_sharess, c(.05, .95))))
describe(news_pop2$self_reference_avg_sharess)
boxplot(news_pop2$self_reference_avg_sharess)

#Normality treatment for number of shares
describe(news_pop2$shares)
boxplot(news_pop2$shares)
news_pop2$shares <- squish(news_pop2$shares, round(quantile(news_pop2$shares, c(.05, .95))))
describe(news_pop2$shares)
boxplot(news_pop2$shares)

describe(news_pop2$min_positive_polarity)
news_pop2$min_positive_polarity <- squish(news_pop2$min_positive_polarity, round(quantile(news_pop2$min_positive_polarity, c(.05, .95))))
describe(news_pop2$min_positive_polarity)

#==============================================#
#Remove unwanted columns
news_pop3 <- subset(news_pop2, select = -c(url, timedelta, is_weekend))
str(news_pop3)

#Convert categorical variables to factors
news_pop3$weekday_is_monday <- factor(news_pop3$weekday_is_monday)
news_pop3$weekday_is_tuesday <- factor(news_pop3$weekday_is_tuesday)
news_pop3$weekday_is_wednesday <- factor(news_pop3$weekday_is_wednesday)
news_pop3$weekday_is_thursday <- factor(news_pop3$weekday_is_thursday)
news_pop3$weekday_is_friday <- factor(news_pop3$weekday_is_friday)
news_pop3$weekday_is_saturday <- factor(news_pop3$weekday_is_saturday)
news_pop3$weekday_is_sunday <- factor(news_pop3$weekday_is_sunday)

news_pop3$data_channel_is_bus <- factor(news_pop3$data_channel_is_bus)
news_pop3$data_channel_is_entertainment <- factor(news_pop3$data_channel_is_entertainment)
news_pop3$data_channel_is_lifestyle <- factor(news_pop3$data_channel_is_lifestyle)
news_pop3$data_channel_is_socmed <- factor(news_pop3$data_channel_is_socmed)
news_pop3$data_channel_is_tech <- factor(news_pop3$data_channel_is_tech)
news_pop3$data_channel_is_world <- factor(news_pop3$data_channel_is_world)

#==============================================#
# Exploratory data analysis

#histograms
hist(news_pop3$n_tokens_title, 
     main = 'Histogram for Title length',
     xlab = 'Title length',
     border = 'black',
     col = 'orange',
     breaks = 5)
# It appears that majority of the articles title length are between 5 to 15 tokens

hist(news_pop3$average_token_length,
     main = 'Histogram for average words length in articles',
     xlab = 'Word length',
     border = 'black',
     col = 'orange',
     breaks = 5)
# The histogram shows that most words within each article have 5 characters.

hist(news_pop3$title_subjectivity,
     main = 'Histogram for title subjectivity',
     xlab = 'Subjectivity',
     border = 'black',
     col = 'purple',
     breaks = 5)

hist(news_pop3$title_sentiment_polarity,
     main = 'Histogram for title sentiment',
     xlab = 'Sentiment polarity',
     border = 'black',
     col = 'yellow',
     breaks = 5)

hist(news_pop3$global_subjectivity,
     main = 'Histogram for articles overall subjectivity',
     xlab = 'Subjectivity',
     border = 'black',
     col = 'green',
     breaks = 5)

hist(news_pop3$global_sentiment_polarity,
     main = 'Histogram for articles overall sentiment',
     xlab = 'Articles sentiment',
     border = 'black',
     col = 'green',
     breaks = 5)

day <- as.data.frame(table(news_pop3$weekday_is_monday,
      news_pop3$weekday_is_tuesday,
      news_pop3$weekday_is_wednesday,
      news_pop3$weekday_is_thursday,
      news_pop3$weekday_is_friday,
      news_pop3$weekday_is_saturday,
      news_pop3$weekday_is_sunday))

write.csv(news_pop3, file = 'Newspop_cleaned.csv')
