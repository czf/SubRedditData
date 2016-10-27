library(RODBC)
library(ggplot2)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=localhost\\SQLEXPRESS;database=SeattleWA_subreddit;trusted_connection=true')
post = sqlQuery(dbhandle, 'select * from post')

julyData <- post[as.Date(post$created_pacific) < as.Date("2016-8-01"),]
julyScore <- post[as.Date(post$created_pacific) < as.Date("2016-8-01"),"score"]
gold <- sum(julyData[,"gilded"])

cat("# gold set to posts:", gold)
cat("# of posts in July: ", length(julyScore)) 
cat("Total score for July: ", sum(julyScore))
cat("Average score for July: ", mean(julyScore))

library(plyr)

postCategoryCount <- count(julyData,"link_flair_text")
postCategoryCount <- postCategoryCount[order(-postCategoryCount$freq),]
print("Frequency of Categories in posts")
print(head(postCategoryCount,n=7),row.names=FALSE)


julyDomainCount <- count(julyData, "domain")
cat("Total unique post domains: ", nrow(julyDomainCount))

julyDomainSum <- aggregate(score ~ domain, julyData, sum)
julyDomainSum <- julyDomainSum[order(-julyDomainSum$score),]

julyDomainCountSum <- merge(julyDomainCount, julyDomainSum)
julyDomainScoreMean <- aggregate( score ~ domain,julyData , mean)
names(julyDomainScoreMean)[2]="mean_score"
julyDomainScoreMean <- julyDomainScoreMean[order(-julyDomainScoreMean$mean_score),]
julyDomainCountMean <- merge(julyDomainScoreMean,julyDomainCount)
julyDomainCountMean <- julyDomainCountMean[order(-julyDomainCountMean$mean_score),]

print("Domains with highest mean score and their frequency.")
print(head(julyDomainCountMean, n=7), row.names=FALSE)

print("Domains with highest frequency and their mean score.")
julyDomainCountMean <- julyDomainCountMean[order(-julyDomainCountMean$freq),]
print(head(julyDomainCountMean, n=7), row.names=FALSE)



julyAuthorCount <- count(julyData,"author")
cat("Total unique post authors: ", nrow(julyAuthorCount))

julyAuthorSum <- aggregate(score ~ author, julyData, sum)
julyAuthorSum <- julyAuthorSum[order(-julyAuthorSum$score),]

julyAuthorCountSum <- merge(julyAuthorCount, julyAuthorSum)
julyAuthorScoreMean <- aggregate( score ~ author,julyData , mean)
names(julyAuthorScoreMean)[2]="mean_score"
julyAuthorScoreMean <- julyAuthorScoreMean[order(-julyAuthorScoreMean$mean_score),]
julyAuthorCountMean <- merge(julyAuthorScoreMean,julyAuthorCount)
julyAuthorCountMean <- julyAuthorCountMean[order(-julyAuthorCountMean$mean_score),]

print("Authors with highest mean score and their frequency.")
print(head(julyAuthorCountMean, n=7), row.names=FALSE)

print("Authors with highest frequency and their mean score.")
julyAuthorCountMean <- julyAuthorCountMean[order(-julyAuthorCountMean$freq),]
print(head(julyAuthorCountMean, n=7), row.names=FALSE)


psaPosts <-julyData[grep("^PSA", julyData$title),c("title","author","score","created_pacific")]
psaAuthorCount <- count(psaPosts,"author")
cat("Total unique PSA post authors: ", nrow(psaAuthorCount))

psaAuthorSum <- aggregate(score ~ author, psaPosts, sum)
psaAuthorSum <- psaAuthorSum[order(-psaAuthorSum$score),]

psaAuthorCountSum <- merge(psaAuthorCount, psaAuthorSum)
psaAuthorScoreMean <- aggregate( score ~ author,psaPosts , mean)
names(psaAuthorScoreMean)[2]="mean_score"
psaAuthorScoreMean <- psaAuthorScoreMean[order(-psaAuthorScoreMean$mean_score),]
psaAuthorCountMean <- merge(psaAuthorScoreMean,psaAuthorCount)
psaAuthorCountMean <- psaAuthorCountMean[order(-psaAuthorCountMean$mean_score),]

print("PSA Authors with highest mean score and their frequency.")
print(head(psaAuthorCountMean, n=7), row.names=FALSE)
if(nrow(psaAuthorCountMean) >5){
  print("PSA Authors with highest frequency and their mean score.")
  psaAuthorCountMean <- psaAuthorCountMean[order(-psaAuthorCountMean$freq),]
  print(head(psaAuthorCountMean, n=7), row.names=FALSE)
}

julyData[,"created_pacific_weekday"] <- strftime(julyData[,"created_pacific"],"%A")
julyData[,"created_pacific_hour"] <- strptime(julyData[,"created_pacific"],"%Y-%m-%d %H:%M:%S")$hour
postHourScore <- count(julyData,"created_pacific_hour","score")
names(postHourScore)[2] = "score"
postHourScore <- postHourScore[order(-postHourScore$score),]
print("Total score for the hour a post is made")
print(head(postHourScore,n=7),row.names=FALSE)

postHourCount <- count(julyData,"created_pacific_hour")
postHourCount <- postHourCount[order(-postHourCount$freq),]
print("Total posts created by hour")
print(head(postHourCount,n=7),row.names=FALSE)

postWeekDayScore <- count(julyData,"created_pacific_weekday","score")
names(postWeekDayScore)[2] = "score"
postWeekDayScore <- postWeekDayScore[order(-postWeekDayScore$score),]
print("Total score for the weekday a post is made")
print(head(postWeekDayScore,n=7),row.names=FALSE)

postWeekDayCount <- count(julyData,"created_pacific_weekday")
postWeekDayCount <- postWeekDayCount[order(-postWeekDayCount$freq),]
print("Total posts created by weekday")
print(head(postWeekDayCount,n=7),row.names=FALSE)


postWeekDayHourCount <- count(julyData,c("created_pacific_weekday","created_pacific_hour"))
hours <- seq(1,24)
w<- weekdays(seq(Sys.Date(),by=1,len=7))
hourw <- merge(w,hours)
names(hourw) = c("created_pacific_weekday","created_pacific_hour")
postWeekDayHourCount <- merge(hourw,postWeekDayHourCount, all.x=TRUE)
postWeekDayHourCount[is.na(postWeekDayHourCount$freq),"freq"]<-0
print("Total posts created by weekday by hour")
postWeekDayHourCount <- postWeekDayHourCount[order(-postWeekDayHourCount$freq),]
print(head(postWeekDayHourCount,n=7), row.names=FALSE)
postWeekDayHourCount <- postWeekDayHourCount[order(postWeekDayHourCount$freq),]
print(head(postWeekDayHourCount,n=7), row.names=FALSE)


