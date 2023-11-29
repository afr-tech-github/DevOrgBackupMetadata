/**
 * Created by khanhpham on 6/19/17.
 */

@IsTest(SeeAllData=false)
private with sharing class DataLoadingControllerTest {
    @IsTest static void shouldLoadButFailToSave() {
        List<String> lines = new List<String>();
        lines.add('CONTAINER NUMBER, CONTAINER SIZE, GROSS WEIGHT, NET WEIGHT (KG), QUANTITY (PACKAGES), MEASUREMENT (CBM), SEAL NUMBER, EMPTY/FULL');
        lines.add('BMOU6260033,40," 17,425.00 ", " 17,425.00 ", 697.00 , 69.70 ,KG281560');
        lines.add('BMOU6210109,40," 17,403.57 ", " 17,425.00 ", 697.00 , 69.70 ,KG225428');
        lines.add('BMOU6041890,40," 17,470.63 ", " 17,425.00 ", 700.00 , 70.00 ,KG281491');

        String fileContent = String.join(lines, '\\\n');
        Blob fileBlob = Blob.valueOf(fileContent);
        PageReference pageReference = Page.DataLoader;
        Test.setCurrentPage(pageReference);

        Test.startTest();
        DataLoadingController controller = new DataLoadingController();
        controller.csvFileBody = fileBlob;
        controller.loadData();
        controller.save();
        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
    }
        
    @IsTest static void shouldLoadFileWithoutHeaders() {
        List<String> lines = new List<String>();
        lines.add('BMOU6260033,40," 17,425.00 ", " 17,425.00 ", 697.00 , 69.70 ,KG281560');
        lines.add('BMOU6210109,40," 17,403.57 ", " 17,425.00 ", 697.00 , 69.70 ,KG225428');
        lines.add('BMOU6041890,40," 17,470.63 ", " 17,425.00 ", 700.00 , 70.00 ,KG281491');

        String fileContent = String.join(lines, '\\\n');
        Blob fileBlob = Blob.valueOf(fileContent);
        PageReference pageReference = Page.DataLoader;
        Test.setCurrentPage(pageReference);

        Test.startTest();
        DataLoadingController controller = new DataLoadingController();
        controller.csvFileBody = fileBlob;
        controller.loadData();
        controller.save();
        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
    }
}