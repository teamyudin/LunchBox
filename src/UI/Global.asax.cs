using System.Web.Mvc;
using System.Web.Routing;
using FluentValidation.Mvc;
using UI.Configuration;
using UI.Helpers.Filters;

namespace UI
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            filters.Add(new RavenSessionAttribute());
        }

        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                "Default", // Route name
                "{controller}/{action}/{id}", // URL with parameters
                new { controller = "Home", action = "Index", id = UrlParameter.Optional } // Parameter defaults
            );

        }

        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            RegisterGlobalFilters(GlobalFilters.Filters);
            RegisterRoutes(RouteTable.Routes);

            StructureMapBootstrapper.Bootstrap();
            AutomapperBootstrapper.Bootstrap();
            ControllerBuilder.Current.SetControllerFactory(new StructureMapControllerFactory());

            FluentValidationModelValidatorProvider.Configure();
        }
    }
}