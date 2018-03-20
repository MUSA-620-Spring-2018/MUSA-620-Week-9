
library(rtweet) #https://cran.r-project.org/web/packages/rtweet/rtweet.pdf
library(tidyverse)

library(lubridate) #functions for date/time data
library(scales) #scales for data visualization
library(stringr) #string manipulation
library(tidytext) #for text mining
library(syuzhet) #corpus


# Some functions in the twitteR package are now out of date
# Going forward, we will be using the rtweet package instead

# !!! IMPORTANT - WHEN SETTING UP YOUR TWEETER APP INCLUDE THIS AS YOUR CALLBACK URL
#Callback URL: http://127.0.0.1:1410

# Authentication for rtweet only requires the consumer keys
# Running the create_token() function below will authenticate you via your web browser

consumer_key <- ""
consumer_secret <- ""
appname <- "MY MUSA620 APP"

twitter_token <- create_token(
  app = appname,
  consumer_key = consumer_key,
  consumer_secret = consumer_secret)

# basic API search
rstats <- search_tweets("#rstats", n = 100, include_rts = FALSE)

# user timeline request
djt100 <- get_timeline("realDonaldTrump", n = 100)



# ****** NLP analysis of @realdonaldtrump tweets by time of day ******
# Hypothesis:
#   Morning tweets tend to be written by Pres. Trump
#   Afternoon tweets tend to be written by his staff
#   Evening tweets can go either way


# Grab the tweets - 3200 is the maximum number of results
djt <- get_timeline("realDonaldTrump", n = 3200)

djttweets <- djt %>%
  select(status_id, source, text, created_at)

djttweets <- mutate(djttweets,hour = hour(with_tz(created_at, "EST")))
djttweets$timeofday <- factor(cut(djttweets$hour, c(-1, 10.5, 19.5,24), c("Morning","Afternoon","Evening")))


# Comparison 1: overall hourly distribution

djttweets %>%
  count(timeofday, hour=hour) %>%
  mutate(percent = n / sum(n)) %>%
  ggplot(aes(hour, percent, color = timeofday)) +
  geom_line() +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Hour of day (EST)", y = "% of tweets", color = "")



# Comparison 2: tweets with images

tweet_picture_counts <- djttweets %>%
  filter(!str_detect(text, '^"')) %>%
  filter(!str_detect(text, '^RT')) %>%
  count(timeofday, picture = ifelse(str_detect(text, "t.co"), "Picture/link", "No picture/link"))

ggplot(tweet_picture_counts, aes(timeofday, n, fill = picture)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "", y = "Number of tweets", fill = "")



# Comparison 3: word frequency

# to tokenize the tweets into words, we will use a regular expression
reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"

# [^ CHARACTERGROUP ] = Matches any single character that is not in CHARACTERGROUP
  # A-Za-z = any letter
  # \d     = any numeric digit
  # #@     = the # or @ symbols

# [^A-Za-z\\d#@'] = Match any character that is not alphanumeric and is not # or @
# This is how it determines where the breaks are between words


# Stop words - common words that convey little meaning, should be removed
stop_words$word


djtWords <- djttweets %>%
  filter(!str_detect(text, '^RT|^"')) %>%                                      # filter tweets starting w/ "rt"
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%   # remove links
  unnest_tokens(word, text, token = "regex", pattern = reg) %>%                     # parse the text into "tokens"
  filter(!word %in% stop_words$word, str_detect(word, "[a-z]"))                     # remove stop words

djtWords %>%
  filter(timeofday == 'Morning') %>%
  count(word, sort = TRUE) %>%
  head(20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_bar(stat = "identity") +
  ylab("Occurrences") +
  coord_flip() +
  labs(title = "Word frequency in @realdonaldtrump tweets: Morning")

djtWords %>%
  filter(timeofday == 'Afternoon') %>%
  count(word, sort = TRUE) %>%
  head(20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_bar(stat = "identity") +
  ylab("Occurrences") +
  coord_flip() +
  labs(title = "Word frequency in @realdonaldtrump tweets: Afternoon")

djtWords %>%
  filter(timeofday == 'Evening') %>%
  count(word, sort = TRUE) %>%
  head(20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_bar(stat = "identity") +
  ylab("Occurrences") +
  coord_flip() +
  labs(title = "Word frequency in @realdonaldtrump tweets: Evening")


# Which words are most likely to be seen in the morning
# and which are most likely to be seen in the afternoon?

morning_afternoon_ratios <- djtWords %>%
  count(word, timeofday) %>%
  filter(sum(n) >= 5) %>%
  spread(timeofday, n, fill = 0) %>%
  ungroup() %>%
  mutate_if(is.numeric, funs((. + 1) / sum(. + 1))) %>%
  mutate(logratio = log2(Morning / Afternoon)) %>%
  arrange(desc(logratio))

morning_afternoon_ratios %>%
  group_by(logratio > 0) %>%
  top_n(15, abs(logratio)) %>%
  ungroup() %>%
  mutate(word = reorder(word, logratio)) %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  ylab("Morning / Afternoon") +
  scale_fill_manual(name = "", labels = c("Morning", "Afternoon"),
                    values = c("red", "lightblue")) +
  labs(title = "Relative word frequency in @realdonaldtrump tweets: morning vs afternoon") +
  myTheme()




# Comparison 4: sentiment analysis

# but before analyzing the tweets, a primer on sentiment analysis using the syuzhet package
# https://cran.r-project.org/web/packages/syuzhet/syuzhet.pdf

# Basic sentiment analysis is quite simple - the words are compared against a corpus
# of "good" and "bad" words. Good words get a positive score. Bad words get a negative score.
# the average score across all words determines the overal sentiment.

wordByWordSentiment1 <- get_sentiment(c("nlp","is","awesome"), method="syuzhet")
overallSentiment1 <- mean(wordByWordSentiment1)

wordByWordSentiment2 <- get_sentiment(c("I","hate","gross","broccoli","it","sucks"), method="syuzhet")
overallSentiment2 <- mean(wordByWordSentiment2)


# The examples above use the "syuzhet" model, which only give a single positive/negative score
# Other sentiment models, such as "nrc", score sentiment across multiple dimensions

NRCSentiment <- get_nrc_sentiment(c("I","hate","gross","broccoli","it","sucks"))
overallNRCSentiment <- summarise_all(myNRCSentiment,funs(mean))


# TOKENIZING
# Earlier, we tokenized the tweets into words using a regular expression
# The syuzhet package has built-in functions for tokenizing text

# We can tokenize a string into words
tokenizedWords <- get_tokens("What a happy joyous day!", pattern = "\\W")


# We can also tokenize a large text into sentences
sou <- readChar('d:/state-of-the-union-2018.txt', file.info(fileName)$size) %>%
  str_replace_all("[\r\n]" , " ") # for cleanup

tokenizedSentences <- get_sentences(sou)


# Likewise, we can run our sentiment analysis on words or on sentences
get_nrc_sentiment(tokenizedWords) %>%
  summarise_all(funs(mean))

get_nrc_sentiment(tokenizedSentences) %>%
  summarise_all(funs(mean))



# Sentiment analysis of @realdonaldtrump tweets

morningWords <- filter(djtWords, timeofday == 'Morning')
afternoonWords <- filter(djtWords, timeofday == 'Afternoon')
eveningWords <- filter(djtWords, timeofday == 'Evening')



# calculate the positive/negative sentiment of tweets from each group

scores <- data.frame()

score <- get_sentiment(eveningWords$word, method="syuzhet") %>%
  mean()
scores <- rbind(scores,data.frame(timeofday="Evening",score=score))

score <- get_sentiment(afternoonWords$word, method="syuzhet") %>%
  mean()
scores <- rbind(scores,data.frame(timeofday="Afternoon",score=score))

score <- get_sentiment(morningWords$word, method="syuzhet") %>%
  mean()
scores <- rbind(scores,data.frame(timeofday="Morning",score=score))


ggplot(scores,aes(x=timeofday, y=score, fill = score > 0)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  ylab("Sentiment") +
  labs(title = "Sentiment of @realdonaldtrump tweets by time of day") +
  scale_fill_manual(name = "", labels = c("Negative", "Positive"),
                  values = c("red", "lightblue"))




# calculate the NRC sentiment scores

nrcScores <- data.frame()

eveningScores <- get_nrc_sentiment(eveningWords$word) %>%
  summarise_all(funs(mean))
nrcScores <- rbind(nrcScores,data.frame(timeofday="Evening",eveningScores))

afternoonScores <- get_nrc_sentiment(afternoonWords$word) %>%
  summarise_all(funs(mean))
nrcScores <- rbind(nrcScores,data.frame(timeofday="Afternoon",afternoonScores))

morningScores <- get_nrc_sentiment(morningWords$word) %>%
  summarise_all(funs(mean))
nrcScores <- rbind(nrcScores,data.frame(timeofday="Morning",morningScores))



tallFormat = gather(nrcScores, key=emotion, value=score, anger:positive)

p <- ggplot(tallFormat,aes(x=timeofday, y=score), fill = "black") +
  geom_bar(stat = "identity") +
  coord_flip() +
  ylab("Sentiment") +
  labs(title = "NRC sentiment of @realdonaldtrump tweets by time of day")

  scale_fill_manual(name = "", labels = c("", "",""),
                    values = c("red", "lightblue","orange"))

p + facet_wrap(~emotion, ncol = 5)







