using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using AutoMapper;
using Core;
using Raven.Client;
using Raven.Json.Linq;
using UI.ViewModels.Menu;
using UI.Helpers;

namespace UI.Controllers
{
    public class MenuController : Controller
    {
        private readonly IDocumentSession _session;

        public MenuController()
        {
        }

        public MenuController(IDocumentSession session)
        {
            _session = session;
        }


        public ActionResult Index()
        {
            var menus = _session.Query<Menu>().ToList().AsEnumerable();

            var viewModel = Mapper.Map<IEnumerable<Menu>, IEnumerable<ShowMenu>>(menus);

            return View(viewModel);
        }


        public FileStreamResult ShowFile(int id)
        {
            var key = RavenDbKey.GenerateKey<Menu>(id);

            var attachment = _session.Advanced.DocumentStore.DatabaseCommands.GetAttachment(key);
            FileStreamResult fs = null;

            if (attachment != null)
            {
                var file = (MemoryStream)attachment.Data();
                var contentType = attachment.Metadata.FirstOrDefault(x => x.Key == "Format").Value.ToString();
                fs = new FileStreamResult(file, contentType);
            }

            return fs;
        }

        public ActionResult Details(int id)
        {
            var menu = _session.Load<Menu>(id);
            var viewModel = Mapper.Map<Menu, ShowMenu>(menu);

            return View(viewModel);
        }

        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Create(CreateEditMenu showMenu)
        {
            try
            {
                var menu = new Menu
                {
                    Name = showMenu.Name
                };
                _session.Store(menu);

                var key = RavenDbKey.GenerateKey<Menu>(menu.Id);
                var stream = showMenu.File.InputStream;
                var optionalMetaData = new RavenJObject();
                optionalMetaData["Format"] = showMenu.File.ContentType;

                _session.Advanced.DocumentStore.DatabaseCommands.PutAttachment(key, null, stream, optionalMetaData);

                return RedirectToAction("Index");
            }
            catch
            {
                ModelState.AddModelError("", "Unable to save changes. Try again, and if the problem persists see your system administrator.");
            }
            return View(showMenu);
        }
        
        public ActionResult Edit(int id)
        {
            var menu = _session.Load<Menu>(id);
            var viewModel = Mapper.Map<Menu, CreateEditMenu>(menu);

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult Edit(CreateEditMenu showMenu)
        {
            try
            {
                var menu = Mapper.Map<CreateEditMenu, Menu>(showMenu);
                _session.Store(menu);

                var key = "menus/" + menu.Id;
                var stream = showMenu.File.InputStream;
                var optionalMetaData = new RavenJObject();
                optionalMetaData["Format"] = showMenu.File.ContentType;

                _session.Advanced.DocumentStore.DatabaseCommands.PutAttachment(key, null, stream, optionalMetaData);

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        public ActionResult Delete(int id)
        {
            var menu = _session.Load<Menu>(id);
            var viewModel = Mapper.Map<Menu, ShowMenu>(menu);

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult Delete(ShowMenu showMenu)
        {
            try
            {
                var menu = _session.Load<Menu>(showMenu.Id);
                _session.Delete(menu);

                var key = "menus/" + menu.Id;
                _session.Advanced.DocumentStore.DatabaseCommands.DeleteAttachment(key, null);

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }
    }
}
