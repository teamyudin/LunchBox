using System.Web.Mvc;
using Raven.Client;
using Raven.Client.Document;
using StructureMap.Configuration.DSL;

namespace UI.Configuration
{
    public class UiRegistry: Registry
    {
        public UiRegistry()
        {
            //Scan(scan =>
            //{
            //    scan.TheCallingAssembly();
            //    scan.WithDefaultConventions();
            //});

            ForSingletonOf<IDocumentStore>().Use(() =>
            {
                var documentStore = new DocumentStore
                                        {
                                            Url = "http://localhost:8080"
                                        };
                documentStore.Initialize();

                return documentStore;
            });

            For<IDocumentSession>().HybridHttpOrThreadLocalScoped().Use(context => context.GetInstance<IDocumentStore>().OpenSession("LunchBox"));

            //For<IControllerFactory>().Use<StructureMapControllerFactory>();
        }
    }
}