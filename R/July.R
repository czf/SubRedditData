library(plyr)
library(RODBC)
library(ggplot2)
require(devtools)
library(wordcloud)
library(tm)
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
dbhandle <- odbcDriverConnect('driver={SQL Server};server=localhost\\SQLEXPRESS;database=SeattleWA_subreddit;trusted_connection=true')
month <- "August"
bigQueryLink <- "https://bigquery.cloud.google.com/table/fh-bigquery:reddit_posts.2016_08"
begin <- "2016-8-01"
end <- "2016-9-01"
postData = sqlQuery(dbhandle, paste('select * from post
 where created_pacific <
                                    \'',end ,'\'
                                    and created_pacific >=\'', begin,'\'', sep=""))
postScore <- postData[,"score"]
numPost<- length(postScore)
gold <- sum(postData[,"gilded"])

cat("# of posts in " , month ,": ", numPost)
cat("# gold set to posts:", gold)
cat("Total post score for posts created in " , month ,": ", sum(postScore))
cat("Average post score for posts created in " , month ,": ", mean(postScore))


postCategoryCount <- count(postData,"link_flair_text")
postCategoryCount <- postCategoryCount[order(-postCategoryCount$freq),]
postCategoryCount$link_flair_text <- factor(postCategoryCount$link_flair_text, levels=postCategoryCount[order(-postCategoryCount$freq),"link_flair_text"])
print("Frequency of Categories(link_flair_text) in posts")
print(head(postCategoryCount,n=7),row.names=FALSE)

postCategoryPlot <- ggplot(data=head(postCategoryCount,n=7), 
                           aes(x=link_flair_text,y=freq, fill=cbPalette[1-7])) +
  geom_bar(width=1,stat="identity") +
  guides(fill=FALSE) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

postCategoryPlot

ggplot(data=postCategoryCount,
       aes(x=factor(1),
           y=postCategoryCount$freq/nrow(postCategoryCount),
           fill=postCategoryCount$link_flair_text
       )
) +
  geom_bar(width=1, stat="identity") +
  labs(x="",y="Percent of Posts", fill="Category", title="Percentage of posts by category") +
  scale_fill_manual(values=rainbow(nrow(postCategoryCount)))


postDomainCount <- count(postData, "domain")
cat("Total unique post domains: ", nrow(postDomainCount))

postDomainSum <- aggregate(score ~ domain, postData, sum)
postDomainSum <- postDomainSum[order(-postDomainSum$score),]

postDomainCountSum <- merge(postDomainCount, postDomainSum)
postDomainScoreMean <- aggregate( score ~ domain,postData , mean)
names(postDomainScoreMean)[2]="mean_score"
postDomainScoreMean <- postDomainScoreMean[order(-postDomainScoreMean$mean_score),]
postDomainCountMean <- merge(postDomainScoreMean,postDomainCount)
postDomainCountMean <- postDomainCountMean[order(-postDomainCountMean$mean_score),]

print("Domains with highest mean post score and their frequency.")
print(head(postDomainCountMean, n=7), row.names=FALSE)

print("Domains with highest post frequency and their mean score.")
postDomainCountMean <- postDomainCountMean[order(-postDomainCountMean$freq),]
print(head(postDomainCountMean, n=7), row.names=FALSE)

domainPlot <- ggplot(data=head(postDomainCountMean,n=7), 
                     aes(x=domain,y=freq, fill=cbPalette[1-7])) +
  geom_bar(width=1,stat="identity") +
  guides(fill=FALSE) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

domainPlot

postAuthorCount <- count(postData,"author")

cat("Total unique post authors: ", nrow(postAuthorCount))

postAuthorSum <- aggregate(score ~ author, postData, sum)
postAuthorSum <- postAuthorSum[order(-postAuthorSum$score),]

postAuthorCountSum <- merge(postAuthorCount, postAuthorSum)
postAuthorScoreMean <- aggregate( score ~ author,postData , mean)
names(postAuthorScoreMean)[2]="mean_score"
postAuthorScoreMean <- postAuthorScoreMean[order(-postAuthorScoreMean$mean_score),]
postAuthorCountMean <- merge(postAuthorScoreMean,postAuthorCount)
postAuthorCountMean <- postAuthorCountMean[order(-postAuthorCountMean$mean_score),]

print("Authors with highest mean post score and their frequency.")
print(head(postAuthorCountMean, n=7), row.names=FALSE)

print("Authors with highest post frequency and their mean score.")
postAuthorCountMean <- postAuthorCountMean[order(-postAuthorCountMean$freq),]
print(head(postAuthorCountMean, n=7), row.names=FALSE)

authorPlot <- ggplot(data=head(postAuthorCountMean,n=7), 
                     aes(x=author,y=freq, fill=cbPalette[1-7])) +
  geom_bar(width=1,stat="identity") +
  guides(fill=FALSE) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

authorPlot

psaPosts <-postData[grep("^PSA", postData$title),c("title","author","score","created_pacific")]
psaAuthorCount <- count(psaPosts,"author")
if(psaAuthorCount==0)
{
  cat("No PSA posts for ", month)
}else
{
  cat("Total unique PSA post authors: ", nrow(psaAuthorCount))
  
  psaAuthorSum <- aggregate(score ~ author, psaPosts, sum)
  psaAuthorSum <- psaAuthorSum[order(-psaAuthorSum$score),]
  
  psaAuthorCountSum <- merge(psaAuthorCount, psaAuthorSum)
  psaAuthorScoreMean <- aggregate( score ~ author,psaPosts , mean)
  names(psaAuthorScoreMean)[2]="mean_score"
  psaAuthorScoreMean <- psaAuthorScoreMean[order(-psaAuthorScoreMean$mean_score),]
  psaAuthorCountMean <- merge(psaAuthorScoreMean,psaAuthorCount)
  psaAuthorCountMean <- psaAuthorCountMean[order(-psaAuthorCountMean$mean_score),]
  
  print("PSA Authors with highest mean post score and their frequency.")
  print(head(psaAuthorCountMean, n=7), row.names=FALSE)
  if(nrow(psaAuthorCountMean) >5){
    print("PSA Authors with highest post frequency and their mean score.")
    psaAuthorCountMean <- psaAuthorCountMean[order(-psaAuthorCountMean$freq),]
    print(head(psaAuthorCountMean, n=7), row.names=FALSE)
  }
}

postData[,"created_pacific_weekday"] <- strftime(postData[,"created_pacific"],"%A")
postData[,"created_pacific_weekday"] <- factor(postData[,"created_pacific_weekday"], levels = c("Sunday","Monday","Tuesday","Wednesday", "Thursday", "Friday", "Saturday"))
postData[,"created_pacific_hour"] <- strptime(postData[,"created_pacific"],"%Y-%m-%d %H:%M:%S")$hour
postHourScore <- count(postData,"created_pacific_hour","score")
names(postHourScore)[2] = "score"
postHourScore <- postHourScore[order(-postHourScore$score),]
print("Total score for the hour a post is made")
print(head(postHourScore,n=7),row.names=FALSE)

postHourCount <- count(postData,"created_pacific_hour")
postHourCount <- postHourCount[order(-postHourCount$freq),]
print("Total posts created by hour")
print(head(postHourCount,n=7),row.names=FALSE)

postWeekDayScore <- count(postData,"created_pacific_weekday","score")
names(postWeekDayScore)[2] = "score"
postWeekDayScore <- postWeekDayScore[order(-postWeekDayScore$score),]
print("Total score for the weekday a post is made")
print(head(postWeekDayScore,n=7),row.names=FALSE)

postWeekDayCount <- count(postData,"created_pacific_weekday")
postWeekDayCount <- postWeekDayCount[order(-postWeekDayCount$freq),]
print("Total posts created by weekday")
print(head(postWeekDayCount,n=7),row.names=FALSE)


postWeekDayHourCount <- count(postData,c("created_pacific_weekday","created_pacific_hour"))
hours <- seq(0,23)
w<- levels(postData$created_pacific_weekday)
hourw <- merge(w,hours)
names(hourw) = c("created_pacific_weekday","created_pacific_hour")
hourw$created_pacific_weekday <- factor(hourw$created_pacific_weekday, levels(postData$created_pacific_weekday))
postWeekDayHourCount <- merge(hourw,postWeekDayHourCount, all.x=TRUE)
postWeekDayHourCount[is.na(postWeekDayHourCount$freq),"freq"]<-0
print("Total posts created by weekday by hour")
postWeekDayHourCount <- postWeekDayHourCount[order(-postWeekDayHourCount$freq),]
print(head(postWeekDayHourCount,n=7), row.names=FALSE)
postWeekDayHourCount <- postWeekDayHourCount[order(postWeekDayHourCount$freq),]
print(head(postWeekDayHourCount,n=7), row.names=FALSE)

ggplot(postWeekDayHourCount, aes(created_pacific_hour,  created_pacific_weekday, size=freq)) + 
  geom_point(shape=21,fill="blue") +
  scale_x_continuous(breaks=seq(0,23,1))  



ggplot(postWeekDayHourCount, 
       aes(x=created_pacific_hour, 
           y=freq, 
           fill=created_pacific_weekday)) + 
  geom_histogram(stat="identity", colour="black") +
  facet_grid(created_pacific_weekday ~ .) +
  theme(legend.position="none") +
  scale_x_continuous(breaks=seq(0,23,1))

p = ggplot(data=postWeekDayCount,
           aes(x=factor(1),
               y=postWeekDayCount$freq/numPost,
               fill=postWeekDayCount$created_pacific_weekday
           )
) +
  geom_bar(width=1, stat="identity") +
  labs(x="",y="Percent of Posts", fill="DayOfWeek", title="Percentage of posts by DayOfWeek") +
  scale_fill_manual(values=cbPalette)

p
