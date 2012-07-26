using AutoMapper;
using Core;
using UI.ViewModels.Menu;

namespace UI.Configuration
{
    public static class AutomapperBootstrapper
    {
        private static bool _shouldlock;

        public static void Bootstrap()
        {
            if (_shouldlock) return;

            Mapper.CreateMap<Menu, ShowMenu>();
            Mapper.CreateMap<ShowMenu, Menu>();
            _shouldlock = true;
        }
    }
}