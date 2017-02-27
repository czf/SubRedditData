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
            string fileName = "1701-comments.json";
            string query = @"SELECT * FROM `fh-bigquery.reddit_comments.2017_01` WHERE subreddit = 'SeattleWA'";


            BigQueryClient client = BigQueryClient.Create("aaaa-153204");
            ProjectReference pr = client.GetProjectReference("fh-bigquery");

            DatasetReference dr = new DatasetReference() { DatasetId = "reddit_comments", ProjectId = pr.ProjectId };

            BigQueryResults result =
                                    client.ExecuteQuery
                                    //(@"SELECT count(1) FROM `fh-bigquery.reddit_comments.2016_11` WHERE subreddit = 'SeattleWA'",
                                    (query,
                                    new ExecuteQueryOptions()
                                    {
                                        DefaultDataset = new DatasetReference()
                                        {
                                            DatasetId = "reddit_comments",
                                            ProjectId = "fh-bigquery"
                                        }
                                    });

            //, new ExecuteQueryOptions() { UseQueryCache = true, DefaultDataset = new DatasetReference() { ProjectId = "fh-bigquery", DatasetId = "reddit_comments" } });
            
            LinkedList<string> rows = new LinkedList<string>();
            while(!result.Completed)
            {
                Console.WriteLine("Polling for completed query");
                result = result.PollUntilCompleted();
            }

            
                
            JsonSerializerSettings serializerSettings = new JsonSerializerSettings() { NullValueHandling = NullValueHandling.Include };


            foreach (BigQueryRow row in result.GetRows( new Google.Api.Gax.PollSettings( 
                Google.Api.Gax.Expiration.None, new TimeSpan(0,0,15))))
            {
                object rowObj = new
                {
                    body = row["body"],
                    score_hidden = (bool?)row["score_hidden"],
                    archived = (bool?) row["archived"],
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

                //    string.Join(",", row.RawRow.F.Select(x => x.V != null ? x.V.ToString(): "null"))
                //);
            }
            System.IO.File.WriteAllLines(@"D:\dev\data\comments\" + fileName, rows);
               
            
            
            Console.ReadLine();
        }
    }
}
