using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.IO;
using System.Threading;
using Newtonsoft.Json;
using System.Data;
using System.Xml;
using System.Data.SqlClient;

namespace JsonToMsSql
{
    class CommentsToSQL
    {

        public static void Main(string[] args)
        {
            
            foreach (string directory in Directory.GetDirectories(@"D:\dev\data\comments\"))
            {
                Console.WriteLine(directory);
                DataSet ds = new DataSet("Json Data");
                string subreddit = directory.Split('\\').Last();
                foreach (string filename in Directory.GetFiles(directory).Where(x => x.EndsWith("-comments.json")))
                {
                    foreach (string line in System.IO.File.ReadLines(filename))
                    {
                        XmlDocument xml = JsonConvert.DeserializeXmlNode(line, "comment");
                        XmlReader xr = new XmlNodeReader(xml);
                        ds.ReadXml(xr);
                    }
                }

                foreach (DataTable dt in ds.Tables)
                {
                    dt.Columns.Add("created_pacific", typeof(DateTime)).SetOrdinal(8);
                    foreach (DataRow row in dt.Rows)
                    {
                        row["downs"] = row["downs"] == null || (string)row["downs"] == string.Empty ? (int?)null : row["downs"];
                        row["ups"] = row["ups"] == null || (string)row["ups"] == string.Empty ? (int?)null : row["ups"];
                        Int32.Parse((string)row["score"]);
                        Int32.Parse((string)row["controversiality"]);
                        Int32.Parse((string)row["gilded"]);
                        //Int32.Parse((string)row["ups"]);
                        row["score_hidden"] = Helpers.convertToBit(row["score_hidden"]);
                        row["archived"] = Helpers.convertToBit(row["archived"]);
                        row["distinguished"] = Helpers.convertToBit(row["distinguished"]);
                        row["created_pacific"] = Helpers.convertToDateTime(row["created_utc"]);

                    }
                }
                if (ds.Tables.Count > 0)
                {
                    Helpers.ToMSSql(ds, subreddit + "_subreddit");
                }
            }
            
        }
    }
}
