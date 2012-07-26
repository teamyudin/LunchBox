using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FluentValidation;
using UI.ViewModels.Menu;

namespace UI.Validators
{
    public class MenuViewItemValidator: AbstractValidator<CreateEditMenu>
    {
        public MenuViewItemValidator()
        {
            RuleFor(menu => menu.Name).NotNull();
            RuleFor(menu => menu.File).NotNull();
        }
    }
}