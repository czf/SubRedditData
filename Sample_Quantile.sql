SELECT
  quantiles( created_utc, 7)
FROM
  [fh-bigquery:reddit_comments.2016_10]
WHERE
  subreddit = 'SeattleWA'