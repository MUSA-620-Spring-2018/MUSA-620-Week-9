# MUSA-620-Week-9
Text mining / natural language processing

![trump tweets relative word frequency](https://github.com/MUSA-620-Spring-2018/MUSA-620-Week-9/blob/master/realdonaldtrump-relative-word-frequency.png "trump tweets relative word frequency")

R data visualizers to follow on Twitter:
* [@aronstrandberg](https://twitter.com/aronstrandberg)
* [@lenkiefer](https://twitter.com/lenkiefer)
* [@dataandme](https://twitter.com/dataandme)

### CoreNLP

- To use [Stanford's CoreNLP](https://stanfordnlp.github.io/CoreNLP/index.html) software, you must have Java installed. If you successfully got Selenium to work, then Java is already installed.
- Download the files [coreNLP.r](https://github.com/MUSA-620-Spring-2018/MUSA-620-Week-9/blob/master/coreNLP.R) and [myProps.properties](https://github.com/MUSA-620-Spring-2018/MUSA-620-Week-9/blob/master/myProps.properties).
- The steps for setup and usage are given in the coreNLP.r script.
- If you want to experiment with CoreNLP's other functionalities, you can find the full list of ["annotators" here](https://stanfordnlp.github.io/CoreNLP/annotators.html). To use them, open your .properties file and add them in manually.


# Assignment <a id="assignment"></a>

Use the Twitter streaming API and sentiment analysis to examine the use of emojis on Twitter.

This assignment is **required**. Please turn it in by email to myself (galkamaxd at gmail) and Evan (ecernea at sas dot upenn dot edu).

**Due:** Wednesday, 28-March by 9am

### Description

The specifics of this assignment are open ended, subject to the following requirements:

* The analysis must involve at a minimum 10,000 tweets, collected via the Twitter streaming API. Search parameters are up to you.
* The tweets must be segmented by some characteristic(s) and compared on the basis of sentiment.
* Emoji use must factor into the analysis.

Examples:

* Are tweets with emojis happier than those without?
* Which emojis are the most positive and which are the most negative?
* Compare the emoji use and sentiment scores of tweets mentioning @realdonaldtrump with those of a random sample of tweets.
* Examine the sentiment and emoji use of [Twitter bots](https://github.com/mkearney/botrnot) vs real users.
* Choose a few emojis whose sentiment is obvious (e.g. angry face, grinning face) and test how well their use correlates with sentiment scores.

### Emoji encodings

Emojis in streamed tweets can be identified by their byte code.

For example, `<ed><a0><bd><ed><b1><8d>` is the byte code for the thumbs up emoji. When you stream in a tweet containing this emoji, such as [this one](https://twitter.com/TheWWEWolfe/status/976187950252863491), its text will appear like this: `<ed><a0><bd><ed><b1><8d>nothing is impossible https://t.co/AckwyTxVjR`.

You can find a full list of emojis and their associated encodings here: [emoji-encodings.csv](https://github.com/MUSA-620-Spring-2018/MUSA-620-Week-9/blob/master/emoji-encodings.csv) in the "streamApiEncodings" column.

Using these codes, you can identify any tweet containing a particular emoji by matching the text of the tweet against that emoji's byte code. See the [emoji-template.r](https://github.com/MUSA-620-Spring-2018/MUSA-620-Week-9/blob/master/emoji-template.r) script for R code to get you started.

**Note:** These emoji encodings work only for the streaming API. If you want to incorporate the REST API in your analysis, the encodings will be different. REST API encodings are also included in [emoji-encodings.csv](https://github.com/MUSA-620-Spring-2018/MUSA-620-Week-9/blob/master/emoji-encodings.csv) in the "restApiEncodings" column.

### Deliverable

- A series of charts displaying your results
- the streaming tweet data you used in your analysis
- all R scripts used in scraping, analyzing, and visualizing the data and anything else I would need to replicate your analysis (without having to collect the tweets myself).
- a written explanation of: the steps you took to create it, any challenges you encountered along the way, and reasons for your design choices

### Notes

- Consider whether you want to include retweets and/or replies in you analysis. Unless you have a reason for including retweets, the default should be to filter them out since they will, in effect, create duplicates in your data.
- You should examine your data manually to make sure the sample you are using is appropriate - should you be filtering out foreign language tweets, highly active users that are skewing the sample?
- You do not have to collect all your data in a single streaming session into one large file. It may be easier to break the task into chunks and combine the data later in R. 
