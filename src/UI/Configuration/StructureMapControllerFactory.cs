using System;
using System.Web.Mvc;
using System.Web.Routing;
using StructureMap;

namespace UI.Configuration
{
    public class StructureMapControllerFactory : DefaultControllerFactory
    {
        protected override IController GetControllerInstance(RequestContext requestContext, Type controllerType)
        {
            return controllerType == null ? null : ObjectFactory.GetInstance(controllerType) as Controller;
        }
    }
}