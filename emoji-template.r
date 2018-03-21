


# Matching a single string against a single keyword
#   If regexpr finds a match, it will return the character position at which the match is found (in the example above, it will return 1).
#   If it does not find a match, regexpr will return -1.

keyword <- "<ed><a0><bd><ed><b1><8d>" # encoding of the "thumbs up emoji"
tweetText <- "<ed><a0><bd><ed><b1><8d>nothing is impossible https://t.co/AckwyTxVjR"

results <- regexpr(keyword,tweetText)




# Matching multiple strings against a multiple keywords

emojiEncodings <- read.csv("d:/emoji-encodings.csv")
tweetTexts <- c("<ed><a0><bd><ed><b1><8d>nothing is impossible https://t.co/AckwyTxVjR","Yesterday was a huge day for our founders <e2><9c><8d><ef><b8><8f><ed><a0><be><ed><b7><a0><ed><a0><bd><ed><b2><a5> Thanks to the @MYOB and @BlueChilliGroup marketing and social media specialis<e2><80><a6>")

results <- sapply(emojiEncodings$streamApiEncodings, regexpr, tweetTexts) %>%
  data.frame()
colnames(results) <- emojiEncodings$emojiDescription

results["THUMBS UP SIGN"]
results["COLLISION SYMBOL"]




# STREAMING API 

access_token <- ""
access_secret <-""
consumer_key <- ""
consumer_secret <- ""

oathfunction <- function(consumer_key, consumer_secret, access_token, access_secret){
  my_oauth <- ROAuth::OAuthFactory$new(consumerKey=consumer_key,
                                       consumerSecret=consumer_secret,
                                       oauthKey=access_token,
                                       oauthSecret=access_secret,
                                       needsVerifier=FALSE, handshakeComplete=TRUE,
                                       verifier="1",
                                       requestURL="https://api.twitter.com/oauth/request_token",
                                       authURL="https://api.twitter.com/oauth/authorize",
                                       accessURL="https://api.twitter.com/oauth/access_token",
                                       signMethod="HMAC")
  return(my_oauth)
}

my_oauth <- oathfunction(consumer_key, consumer_secret, access_token, access_secret)

# Set the parameters of your stream
# Keep in mind that most of these parameters will not work together
# For example, the location search cannot be paired with other parameters

file = "d:/mytwitterstream.json"       #The data will be saved to this file as long as the stream is running
track = NULL # c("#maga")                 #"Search" by keyword(s)
follow = NULL #c("pepsi","cocacola","7up")                           #"Search" by Twitter user(s)
loc = NULL #c(-179, -70, 179, 70)             #Geographical bounding box -- (min longitute,min latitude,max longitute,max latitude)
lang = NULL                             #Filter by language
timeout = NULL #1000                          #Maximum time (in miliseconds)
tweets = 100 #1000                      #Maximum tweets (usually, it will be less)


filterStream(file.name = file, 
             track = track,
             follow = follow, 
             locations = loc, 
             language = lang,
             #timeout = timeout, 
             tweets = tweets, 
             oauth = my_oauth,
             verbose = TRUE)

streamedtweets <- parseTweets(file, verbose = FALSE)

# IMPORTANT - for the emojis to be properly encoded, you must use the line below
streamedtweets$text <- iconv(streamedtweets$text , from = "latin1", to = "ascii", sub = "byte")



# OPTIONAL - If you want to use the REST API (rtweet package) in your analysis, you should use this command to encode the emojis
restAPI$text <- iconv(restAPI$text , from = "latin1", to = "ascii", sub = "byte")


