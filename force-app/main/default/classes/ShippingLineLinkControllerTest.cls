/**
 * Created by khanhpham on 5/7/17.
 */

@IsTest
private class ShippingLineLinkControllerTest {
    @IsTest static void shouldReturnShippingLineLinks() {
        ShippingLineLinkController controller = new ShippingLineLinkController();

        Test.startTest();
        controller.setUpLinks();
        Test.stopTest();

        System.assertNotEquals(null, controller.shippingLineLinks);
    }
}