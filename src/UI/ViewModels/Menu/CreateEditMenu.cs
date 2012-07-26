using System.Web;
using FluentValidation.Attributes;
using UI.Validators;

namespace UI.ViewModels.Menu
{
    [Validator(typeof(MenuViewItemValidator))]
    public class CreateEditMenu
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public HttpPostedFileBase File { get; set; }
    }
}