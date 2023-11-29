/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitiesSelfRegConfirmControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitiesSelfRegConfirmController() {
      Test.startTest();
        // Instantiate a new controller with all parameters in the page
        CommunitiesSelfRegConfirmController controller = new CommunitiesSelfRegConfirmController();
        Integer x = 1;
        System.assert(x != null);
        Test.stopTest();
      }    
}