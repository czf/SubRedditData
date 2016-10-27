﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Data.SqlClient;
using System.Data;

namespace JsonToMsSql
{
    public static class Helpers
    {
        public static bool? convertToBit(object rowElement)
        {
            return rowElement == null ? (bool?)null : (string)rowElement == "true";
        }

        public static DateTime FromUnixTime(long unixTime)
        {
            var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return epoch.AddSeconds(unixTime);
        }
        public static DateTime convertToDateTime(object rowElement)
        {
            long utcEpoch = long.Parse((string)rowElement);

            DateTime utcDateTime = FromUnixTime(utcEpoch);
            return TimeZoneInfo.ConvertTimeFromUtc(utcDateTime, TimeZoneInfo.Local);
        }

        public static void ToMSSql(DataSet ds)
        {
            using (SqlConnection conn = new SqlConnection("Data Source=DRTUJK\\SQLEXPRESS;Database=SeattleWA_subreddit;Integrated Security=True;"))
            {
                conn.Open();
                foreach (DataTable dt in ds.Tables)
                {
                    Console.WriteLine("Bulk Insert Started table:" + dt.TableName);
                    SqlBulkCopy bulk = new SqlBulkCopy(conn);

                    bulk.DestinationTableName = "[" + dt.TableName.Replace('{', ' ').Replace('}', ' ') + "]";
                    bulk.WriteToServer(dt);
                    Console.WriteLine("Bulk Insert completed table:" + dt.TableName);
                }
            }
        }
    }
}