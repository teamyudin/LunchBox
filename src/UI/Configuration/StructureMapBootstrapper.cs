using System.Diagnostics;
using StructureMap;

namespace UI.Configuration
{
    public class StructureMapBootstrapper
    {
        public static void Bootstrap()
        {
            new StructureMapBootstrapper().BootstrapStructureMap();
        }

        public StructureMapBootstrapper BootstrapStructureMap()
        {
            ObjectFactory.Initialize(x => x.AddRegistry<UiRegistry>());
            Debug.WriteLine(ObjectFactory.Container.WhatDoIHave());
            return this;
        }
    }
}