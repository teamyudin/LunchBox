using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace UI.Helpers
{
    public class RavenDbKey
    {
        public static string GenerateKey<T>(int id) where T : class
        {
            var type = typeof(T);

            var key = Formatting.Pluralize(2, type.Name.ToLower()) + "/" + id;
            return key;
        }
    }
}