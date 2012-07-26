using TechTalk.SpecFlow;
using UI.Controllers;
using UnitTests.Support;

namespace UnitTests.Steps
{
    [Binding]
    public class AddNewMenuSteps
    {
        [Given(@"I have selected a menu file from a local drive")]
        public void GivenIHaveSelectedAMenuFileFromALocalDrive()
        {
            ScenarioContext.Current.Pending();
        }

        [When(@"I press add")]
        public void WhenIPressAdd()
        {
            ScenarioContext.Current.Pending();
        }

        [Then(@"repository should contain selected menu")]
        public void ThenRepositoryShouldContainSelectedMenu()
        {
            ScenarioContext.Current.Pending();
        }

        private AdminController GetAdminController()
        {
            var controller = new AdminController();
            HttpContextStub.SetupController(controller);
            return controller;
        }

    }
}
