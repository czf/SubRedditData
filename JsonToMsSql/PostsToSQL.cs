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
    class PostsToSQL
    {
        public static void Main(string[] args)
        {

            DataSet ds = new DataSet("Json Data");
            foreach (string filename in Directory.GetFiles(@"D:\dev\data\posts\").Where(x => x.EndsWith("-posts.json")))
            {
                foreach (string line in System.IO.File.ReadLines(filename))//@"D:\dev\data\posts\1608-posts.json"
                {
                    XmlDocument xml = JsonConvert.DeserializeXmlNode(line, "post");
                    XmlReader xr = new XmlNodeReader(xml);
                    ds.ReadXml(xr);
                }
            }

            foreach (DataTable dt in ds.Tables)
            {
                dt.Columns.Add("created_pacific", typeof(DateTime)).SetOrdinal(1);
                foreach (DataRow row in dt.Rows)
                {
                    row["saved"] = Helpers.convertToBit(row["saved"]);
                    row["stickied"] = Helpers.convertToBit(row["stickied"]);
                    row["over_18"] = Helpers.convertToBit(row["over_18"]);
                    row["hide_score"] = Helpers.convertToBit(row["hide_score"]);
                    row["archived"] = Helpers.convertToBit(row["archived"]);
                    row["is_self"] = Helpers.convertToBit(row["is_self"]);
                    row["quarantine"] = Helpers.convertToBit(row["quarantine"]);
                    row["distinguished"] = Helpers.convertToBit(row["distinguished"]);

                    //row["created_utc"] = Int32.Parse(row["created_utc"].ToString());
                    //row["num_comments"] = Int32.Parse(row["num_comments"].ToString());
                    //row["score"] = int.Parse(row["score"].ToString());
                    int i = 0;
                    row["ups"] = int.TryParse(row["ups"].ToString(), out i) ? i : (int?)null ;
                    row["downs"] = int.TryParse(row["downs"].ToString(), out i) ? i : (int?)null;
                    //row["retrieved_on"] = Int32.Parse(row["retrieved_on"].ToString());
                    row["created_pacific"] = Helpers.convertToDateTime(row["created_utc"]);

                }
            }


            Helpers.ToMSSql(ds);


        }
    }
}
