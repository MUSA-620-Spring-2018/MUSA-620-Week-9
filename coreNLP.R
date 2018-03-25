

library(coreNLP) #https://cran.r-project.org/web/packages/coreNLP/coreNLP.pdf

# if this is your first time using coreNLP, run this command to download coreNLP
downloadCoreNLP()

# point this command to your .properties file and run to initialize coreNLP 
initCoreNLP(mem = "4g",type = c("english"), parameterFile="myProps.properties")

# usage
texts <- c("I love kale!","Tofu is gross")
annoObj <- annotateString(texts) 
getToken(annoObj)
getSentiment(annoObj)

