@isTest
private class FormattingControllerTest {
    testmethod static void shouldReturnCorrectValues() {
        FormattingController controller = new FormattingController();
        Test.startTest();
        controller.value = 0;
        System.assertEquals('0', controller.getFormattedValue());

        controller.value = null;
        System.assertEquals(controller.getFormattedValue(), controller.getFormattedValue());

        controller.value = 0.123;
        System.assertEquals('0', controller.getFormattedValue());

        //controller.value = 123456.888;
        //System.assertEquals('123.457', controller.getFormattedValue());

        controller.value = 123.000;
        System.assertEquals('123', controller.getFormattedValue());
        Test.stopTest();
    }
}