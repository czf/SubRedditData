library(plyr)
library(RODBC)
library(ggplot2)
require(devtools)
library("wordcloud")
library(tm)

dbhandle <- odbcDriverConnect('driver={SQL Server};server=localhost\\SQLEXPRESS;database=SeattleWA_subreddit;trusted_connection=true')
commData <- sqlQuery(dbhandle, 'select comment.*, post.domain, post.author as \'post_author\' 
, post.link_flair_text 
from comment
inner join post on SUBSTRING(comment.link_id,4, len(comment.link_id)) = post.id
                where comment.created_pacific <\'2016-8-01\'')
commScore <- commData[,"score"]
month <-"july"
gold <- sum(commData[,"gilded"])
cat("# gold set to comments:", gold)
numComm <-NROW(commData)
cat("# of comments in ", month,": ", numComm) 
cat("Total score for ", month,": ", sum(commScore))
cat("Average score for ", month,": ", mean(commScore))


commAuthorCount <- count(commData,"author")
meanAuthorScore <- aggregate(score ~ author, commData, mean)
names(meanAuthorScore)[2] = "mean_score"
sumAuthorScore <- aggregate(score ~ author, commData, sum)
names(sumAuthorScore)[2] = "total_score"

commAuthorData <- merge(merge(commAuthorCount, meanAuthorScore),sumAuthorScore)
commAuthorData <-commAuthorData[order(-commAuthorData$freq,-commAuthorData$mean_score),]
print("most frequent commentors, their avg and total score")

commOnPostCategory <- aggregate( rep(1,nrow(commData)) ~ link_flair_text + link_id,commData,sum)
names(commOnPostCategory)[3] <- "count"
commOnPostCategoryMean <- aggregate(count ~ link_flair_text,commOnPostCategory,mean)
names(commOnPostCategoryMean)[2] <-"mean_count"
commOnPostCategoryData <- merge(commOnPostCategoryMean,count(commData,"link_flair_text"))
names(commOnPostCategoryData)[3] <-"count"
commOnPostCategoryData <- commOnPostCategoryData[order(-commOnPostCategoryData$count, -commOnPostCategoryData$mean_count),]
print("comments on posts by category")
print(head(commOnPostCategoryData, n=7),row.names = FALSE)



commData[,"created_pacific_weekday"] <- strftime(commData[,"created_pacific"],"%A")
commData[,"created_pacific_hour"] <- strptime(commData[,"created_pacific"],"%Y-%m-%d %H:%M:%S")$hour

commHourScore <- count(commData,"created_pacific_hour","score")
names(commHourScore)[2] = "score"
commHourScore <- commHourScore[order(-commHourScore$score),]
print("Total score for the hour a comment is made")
print(head(commHourScore,n=7),row.names=FALSE)

commHourCount <- count(commData,"created_pacific_hour")
commHourCount <- commHourCount[order(-commHourCount$freq),]
print("Total comments created by hour")
print(head(commHourCount,n=7),row.names=FALSE)

commWeekDayScore <- count(commData,"created_pacific_weekday","score")
names(commWeekDayScore)[2] = "score"
commWeekDayScore <- commWeekDayScore[order(-commWeekDayScore$score),]
print("Total score for the weekday a comment is made")
print(head(commWeekDayScore,n=7),row.names=FALSE)

commWeekDayCount <- count(commData,"created_pacific_weekday")
commWeekDayCount <- commWeekDayCount[order(-commWeekDayCount$freq),]
print("Total comments created by weekday")
print(head(commWeekDayCount,n=7),row.names=FALSE)


commWeekDayHourCount <- count(commData[,],c("created_pacific_weekday","created_pacific_hour"))
hours <- seq(1,24)
w<- weekdays(seq(Sys.Date(),by=1,len=7))
hourw <- merge(w,hours)
names(hourw) = c("created_pacific_weekday","created_pacific_hour")
commWeekDayHourCount <- merge(hourw,commWeekDayHourCount, all.x=TRUE)
commWeekDayHourCount[is.na(commWeekDayHourCount$freq),"freq"]<-0
print("Total comments created by weekday by hour")
commWeekDayHourCount <- commWeekDayHourCount[order(-commWeekDayHourCount$freq),]
print(head(commWeekDayHourCount,n=7), row.names=FALSE)
commWeekDayHourCount <- commWeekDayHourCount[order(commWeekDayHourCount$freq),]
print(head(commWeekDayHourCount,n=7), row.names=FALSE)


textData <- commData$body
textData = gsub("[[:punct:]]", "", textData)
textData = gsub("[[:digit:]]", "", textData)
textData = gsub("http\\w+", "", textData)
textData = gsub("[ \t]{2,}", "", textData)
textData = gsub("^\\s+|\\s+$", "", textData)
try.error = function(x)
{
  y = NA
  try_error = tryCatch(tolower(x), error=function(e) e)
  if (!inherits(try_error, "error"))
    y = tolower(x)
  return(y)
}
textData = sapply(textData, try.error)
textData = textData[!is.na(textData)]
names(textData) = NULL


# Create corpus
corpus=Corpus(textData)

# Convert to lower-case
corpus=tm_map(corpus,tolower)

# Remove stopwords
corpus=tm_map(corpus,function(x) removeWords(x,stopwords()))

# convert corpus to a Plain Text Document
corpus=tm_map(corpus,PlainTextDocument)
col=brewer.pal(10,"Dark2")
wordcloud(corpus, min.freq=25, scale=c(5,2),rot.per = 0.25,
          random.color=T, max.word=45, random.order=F,colors=col)