@isTest
private class NavigationFlowControllerTest {
    testMethod static void shouldInitializeNavigationFlow() {
        PageReference pageRef = Page.NavigationFlow;
        Test.setCurrentPage(pageRef);
        NavigationFlowController controller = new NavigationFlowController();
        System.assert(true);
    }
}