using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Google.Apis.Auth.OAuth2;
using Google.Apis.Bigquery.v2;
using Google.Apis.Bigquery.v2.Data;
using Google.Apis.Json;
using Google.Apis.Services;
using Google.Cloud.BigQuery.V2;
using Newtonsoft.Json;

namespace BigQueryExecute
{
    class Program
    {
        public static void Main(string[] args)
        {
            //format should be YYMM-comments.json"
            Stack<string> dbDates = new Stack<string>(new List<string>() {
                "16_07",
                "16_08",
                "16_09",
                "16_10",
                "16_11",
                "16_12",
                "17_01",
                "17_02",
                "17_03",
                "17_04",
                "17_05",
                "17_06",
            });

            string dbDate = "17_06";
            string subreddit = "Seattle";
            string dataset = "posts";
            //string dataset = "comments";

            BigQueryClient client = BigQueryClient.Create("aaaa-153204");
            ProjectReference pr = client.GetProjectReference("fh-bigquery");
            

            DatasetReference dr = new DatasetReference() { DatasetId = $"reddit_{dataset}", ProjectId = pr.ProjectId };

            JsonSerializerSettings serializerSettings = new JsonSerializerSettings() { NullValueHandling = NullValueHandling.Include };
            while (dbDates.Count > 0)
            {
                dbDate = dbDates.Pop();


                string fileName = $"{dbDate.Replace("_", "")}-{dataset}.json";
                string query = $@"SELECT * FROM `fh-bigquery.reddit_{dataset}.20{dbDate}` WHERE subreddit = '{subreddit}'";
                BigQueryResults result =
                                        client.ExecuteQuery
                                        //(@"SELECT count(1) FROM `fh-bigquery.reddit_comments.2016_11` WHERE subreddit = 'SeattleWA'",
                                        (query,
                                        new ExecuteQueryOptions()
                                        {
                                            DefaultDataset = new DatasetReference()
                                            {
                                                DatasetId = $"reddit_{dataset}",
                                                ProjectId = "fh-bigquery"
                                            }
                                        });

                //, new ExecuteQueryOptions() { UseQueryCache = true, DefaultDataset = new DatasetReference() { ProjectId = "fh-bigquery", DatasetId = "reddit_comments" } });

                LinkedList<string> rows = new LinkedList<string>();
                while (!result.Completed)
                {
                    Console.WriteLine("Polling for completed query");
                    result = result.PollUntilCompleted();
                }



                


                foreach (BigQueryRow row in result.GetRows(new Google.Api.Gax.PollSettings(
                    Google.Api.Gax.Expiration.None, new TimeSpan(0, 0, 15))))
                {

                    if (dataset == "comments")
                    {
                        object rowObj = new
                        {
                            body = row["body"],
                            score_hidden = (bool?)row["score_hidden"],
                            archived = (bool?)row["archived"],
                            name = row["name"],
                            author = row["author"],
                            author_flair_text = row["author_flair_text"],
                            downs = (long?)row["downs"],
                            created_utc = (long?)row["created_utc"],
                            subreddit_id = row["subreddit_id"],
                            link_id = row["link_id"],
                            parent_id = row["parent_id"],
                            score = (long?)row["score"],
                            retrieved_on = (long?)row["retrieved_on"],
                            controversiality = (long?)row["controversiality"],
                            gilded = (long?)row["gilded"],
                            id = row["id"],
                            subreddit = row["subreddit"],
                            ups = (long?)row["ups"],
                            distinguished = row["distinguished"],
                            author_flair_css_class = row["author_flair_css_class"]
                        };



                        rows.AddLast(
                            JsonConvert.SerializeObject(rowObj,
                            Formatting.None,
                            serializerSettings
                            ));
                    }
                    else
                    {
                        object rowPostObj = new
                        {
                            created_utc = (long?)row["created_utc"],
                            subreddit = row["subreddit"],
                            author = row["author"],
                            domain = row["domain"],
                            url = row["url"],
                            num_comments = (long?)row["num_comments"],
                            score = (long?)row["score"],
                            ups = (long?)row["ups"],
                            downs = (long?)row["downs"],
                            title = row["title"],
                            selftext = row["selftext"],
                            saved = (bool?)row["saved"],
                            id = row["id"],
                            from_kind = row["from_kind"],
                            gilded = (long?)row["gilded"],
                            from = row["from"],
                            stickied = (bool?)row["stickied"],
                            retrieved_on = (long?)row["retrieved_on"],
                            over_18 = (bool?)row["over_18"],
                            thumbnail = row["thumbnail"],
                            subreddit_id = row["subreddit_id"],
                            hide_score = (bool?)row["hide_score"],
                            link_flair_css_class = row["link_flair_css_class"],
                            author_flair_css_class = row["author_flair_css_class"],
                            archived = (bool?)row["archived"],
                            is_self = (bool?)row["is_self"],
                            from_id = row["from_id"],
                            permalink = row["permalink"],
                            name = row["name"],
                            author_flair_text = row["author_flair_text"],
                            quarantine = (bool?)row["quarantine"],
                            link_flair_text = row["link_flair_text"],
                            distinguished = row["distinguished"]
                        };
                        rows.AddLast(
                           JsonConvert.SerializeObject(rowPostObj,
                           Formatting.None,
                           serializerSettings
                           ));
                    }

                    //    string.Join(",", row.RawRow.F.Select(x => x.V != null ? x.V.ToString(): "null"))
                    //);
                }
                System.IO.File.WriteAllLines(@"D:\dev\data\" + dataset + "\\" +subreddit+ "\\" + fileName, rows);

            }
            Console.WriteLine("Complete");
            
            Console.ReadLine();
        }
    }
}
