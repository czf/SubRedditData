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
    class Program
    {

        static void Main(string[] args)
        {
            PostsToSQL.Main(null);
            CommentsToSQL.Main(null);
            Console.WriteLine("***************************************");
            Console.WriteLine("\t\t\t\tComplete\t\t\t");
            Console.WriteLine("***************************************");
            Console.ReadLine();
        }
    }
}
