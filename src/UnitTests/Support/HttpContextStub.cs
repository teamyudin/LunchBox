using System.Collections.Generic;
using System.Web;
using System.Web.Mvc;
using Moq;
using TechTalk.SpecFlow;

namespace UnitTests.Support
{
    [Binding]
    public class HttpContextStub
    {
        class StubSession : HttpSessionStateBase
        {
            readonly Dictionary<string, object> _state = new Dictionary<string, object>();
            public override object this[string name]
            {
                get
                {
                    if (!_state.ContainsKey(name))
                        return null;
                    return _state[name];
                }
                set
                {
                    _state[name] = value;
                }
            }
        }

        private static StubSession _sessionStub;

        [BeforeScenario]
        public void CleanReferenceBooks()
        {
            _sessionStub = null;
        }

        public static HttpContextBase Get()
        {
            var httpContextStub = new Mock<HttpContextBase>();
            if (_sessionStub == null)
            {
                _sessionStub = new StubSession();
            }
            httpContextStub.SetupGet(m => m.Session).Returns(_sessionStub);
            return httpContextStub.Object;
        }

        public static void SetupController(Controller controller)
        {
            controller.ControllerContext = new ControllerContext {HttpContext = Get()};
        }
    }
}
