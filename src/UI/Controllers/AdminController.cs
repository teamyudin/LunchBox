using System.IO;
using System.Web;
using System.Web.Mvc;

namespace UI.Controllers
{
    public class AdminController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }
    }
}
