library(plyr)
library(RODBC)
library(ggplot2)
require(devtools)
library(wordcloud)
library(tm)
begin <- "2016-7-01"
end <- "2016-8-01"
month <-"july"

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
dbhandle <- odbcDriverConnect('driver={SQL Server};server=localhost\\SQLEXPRESS;database=SeattleWA_subreddit;trusted_connection=true')
commData <- sqlQuery(dbhandle, paste('select comment.*, post.domain, post.author as \'post_author\' 
, post.link_flair_text 
from comment
inner join post on replace(comment.link_id,\'t3_\',\'\') = post.id
                where comment.created_pacific <
\'',end ,'\'
and comment.created_pacific >=\'', begin,'\'', sep=""))

commScore <- commData[,"score"]


numComm <-NROW(commData)
cat("# of comments in ", month,": ", numComm) 
gold <- sum(commData[,"gilded"])
cat("# gold set to comments:", gold)
cat("Total comment score for comments in", month,": ", sum(commScore))
cat("Average comment score for comments in", month,": ", mean(commScore))


commAuthorCount <- count(commData,"author")
meanAuthorScore <- aggregate(score ~ author, commData, mean)
names(meanAuthorScore)[2] = "mean_score"
sumAuthorScore <- aggregate(score ~ author, commData, sum)
names(sumAuthorScore)[2] = "total_score"

commAuthorData <- merge(merge(commAuthorCount, meanAuthorScore),sumAuthorScore)
commAuthorData <-commAuthorData[order(-commAuthorData$freq,-commAuthorData$mean_score),]
print("most frequent commentors, their avg and total score")
print(head(commAuthorData, n=7), row.names=FALSE)
authorPlot <- ggplot(data=head(commAuthorData,n=7), 
                     aes(x=author,y=freq, fill=cbPalette[1-7])) +
  geom_bar(width=1,stat="identity") +
  guides(fill=FALSE) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

authorPlot

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
commData[,"created_pacific_weekday"] <- factor(commData[,"created_pacific_weekday"], levels = c("Sunday","Monday","Tuesday","Wednesday", "Thursday", "Friday", "Saturday"))
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


commWeekDayHourCount <- count(commData,c("created_pacific_weekday","created_pacific_hour"))
hours <- seq(0,23)
w<- levels(commData$created_pacific_weekday)
hourw <- merge(w,hours)
names(hourw) = c("created_pacific_weekday","created_pacific_hour")
hourw$created_pacific_weekday <- factor(hourw$created_pacific_weekday, levels(commData$created_pacific_weekday))
commWeekDayHourCount <- merge(hourw,commWeekDayHourCount, all.x=TRUE)
commWeekDayHourCount[is.na(commWeekDayHourCount$freq),"freq"]<-0
print("Total comments created by weekday by hour")
commWeekDayHourCount <- commWeekDayHourCount[order(-commWeekDayHourCount$freq),]
print(head(commWeekDayHourCount,n=7), row.names=FALSE)
commWeekDayHourCount <- commWeekDayHourCount[order(commWeekDayHourCount$freq),]
print(head(commWeekDayHourCount,n=7), row.names=FALSE)

punchCardPlot <- ggplot(commWeekDayHourCount, aes(created_pacific_hour,  created_pacific_weekday, size=freq)) + 
  geom_point(shape=21,fill="blue") +
  scale_x_continuous(breaks=seq(0,23,1))  
  
punchCardPlot


ggplot(commWeekDayHourCount, 
       aes(x=created_pacific_hour, 
           y=freq, 
           fill=created_pacific_weekday)) + 
  geom_histogram(stat="identity", colour="black") +
  facet_grid(created_pacific_weekday ~ .) +
  theme(legend.position="none") +
  scale_x_continuous(breaks=seq(0,23,1))

p = ggplot(data=commWeekDayCount,
           aes(x=factor(1),
               y=commWeekDayCount$freq/numComm,
               fill=commWeekDayCount$created_pacific_weekday
           )
) +
  geom_bar(width=1, stat="identity") +
  labs(x="",y="Percent of Comment", fill="DayOfWeek", title="Percentage of comments by DayOfWeek") +
  scale_fill_manual(values=cbPalette)

p


textData <- commData$body
nimbyCount <- length(textData[grep("NIMBies|NIMBY", textData,ignore.case = TRUE)])
cat("Total comments using 'Nimby' or 'Nimbies': ", nimbyCount)

deletedCount <- length(textData[grep("^\\[deleted\\]", textData,ignore.case = TRUE)])
removedCount <- length(textData[grep("^\\[removed\\]", textData,ignore.case = TRUE)])

cat("Total comments deleted by user:", deletedCount )
cat("Total comments removed by mod:", removedCount )

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
corpus=Corpus(VectorSource(textData))


# Convert to lower-case
corpus=tm_map(corpus,tolower)

# Remove stopwords
corpus=tm_map(corpus,function(x) removeWords(x,stopwords()))

corpus=tm_map(corpus, stemDocument)
corpus=tm_map(corpus, stripWhitespace)
# convert corpus to a Plain Text Document
corpus=tm_map(corpus,PlainTextDocument)
col=brewer.pal(8,"Dark2")
wordcloud(corpus, min.freq=25, scale=c(5,2),rot.per = 0.25,
          random.color=T, max.word=45, random.order=F,colors=col)






