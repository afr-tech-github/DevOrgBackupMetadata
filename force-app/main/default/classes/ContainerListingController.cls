/**
 * Created by khanhpham on 10/25/17.
 */

public with sharing class ContainerListingController {
    private static final Integer PAGE_SIZE = 20;
    private String shipmentId;
    public List<ContainerListingPageWrapper> pages {get; private set;}
    public Date printDate {get; private set;}
    public String invoiceNo {get; private set;}
    public Integer numberOfPages {get; private set;}
    public Boolean fullList {get; private set;}

    public ContainerListingController() {
        readParameters();
    }

    public void buildContainerLists() {
        buildReportData();

        numberOfPages = 0;

        if (pages != null && !pages.isEmpty()) {
            numberOfPages = pages.size();
        }
    }

    private void readParameters() {
        shipmentId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID));

        try {
            fullList = Boolean.valueOf(ApexPages.currentPage().getParameters().get(Constants.REQUEST_CHECK_FLAG));
        } catch (Exception e) {
            fullList = true;
        }
    }

    private void buildReportData() {
        CustomObject1__c shipment = [
                SELECT MASTER_BOOKINGNO__c, POD__r.Name, POL__r.Name, ETD__c, ETA__c, PrintDate__c, WkInitial__c, QuotationVer__c, Name, DevanningDate__c,
                    (SELECT Id, DeclarationNo__c, Customs_Release_Day__c FROM Custom_Clearance__r),
                    (SELECT Id, Name, Container__c, Container_NO__c, Empty_Full_Container_Identification__c FROM Container_Info__r)
                FROM CustomObject1__c
                WHERE Id = :shipmentId
        ];

        if (shipment != null) {
            printDate = shipment.PrintDate__c;
            invoiceNo = 'S' + shipment.WkInitial__c + shipment.Name + '-' + shipment.QuotationVer__c;

            List<Container_Info__c> containerInfos = shipment.Container_Info__r;

            if (containerInfos != null && !containerInfos.isEmpty()) {
                List<Custom_Clearance__c> customClearances = shipment.Custom_Clearance__r;
                Custom_Clearance__c customClearance = null;

                if (customClearances != null && !customClearances.isEmpty()) {
                    customClearance = customClearances.get(0);
                }

                Integer lineCount = 0;
                Integer index = 0;
                Integer pageNo = 0;
                pages = new List<ContainerListingPageWrapper>();
                ContainerListingPageWrapper page = null;

                for (Container_Info__c containerInfo : containerInfos) {
                    lineCount++;
                    if (lineCount == 1) {
                        pageNo++;
                        page = new ContainerListingPageWrapper();
                        page.pageNo = pageNo;
                        pages.add(page);
                    } else if (lineCount == PAGE_SIZE) {
                        lineCount = 0;
                    }

                    ContainerListingLineWrapper line = new ContainerListingLineWrapper();
                    line.index = ++index;
                    line.bookingNumber = shipment.MASTER_BOOKINGNO__c;
                    line.portOfDischarge = shipment.POD__r.Name;
                    line.portOfLoading = shipment.POL__r.Name;
                    line.etd = shipment.ETD__c;
                    line.eta = shipment.ETA__c;
                    line.stuffingUnstuffingDate = shipment.DevanningDate__c;

                    if (customClearance != null) {
                        line.appDeclarationNo = customClearance.DeclarationNo__c;
                        line.ccPermitDate = customClearance.Customs_Release_Day__c;
                    }

                    line.containerId = containerInfo.Name;
                    line.containerType = containerInfo.Container__c;
                    line.containerNumber = containerInfo.Container_NO__c;
                    line.fullOrEmpty = containerInfo.Empty_Full_Container_Identification__c;

                    page.addLine(line);
                }
            }
        }
    }

    class ContainerListingPageWrapper {
        public Integer pageNo {get; set;}
        public List<ContainerListingLineWrapper> lines { get; private set; }

        public ContainerListingPageWrapper() {
            lines = new List<ContainerListingLineWrapper>();
        }

        public void addLine(ContainerListingLineWrapper line) {
            lines.add(line);
        }
    }

    class ContainerListingLineWrapper {
        public Integer index { get; set; }
        public String bookingNumber { get; set; }
        public String portOfDischarge { get; set; }
        public String portOfLoading { get; set; }
        public Date etd { get; set; }
        public Date eta { get; set; }
        public Date stuffingUnstuffingDate {get; set;}
        public String appDeclarationNo { get; set; }
        public Date ccPermitDate { get; set; }
        public String containerId { get; set; }
        public String containerType { get; set; }
        public String containerNumber { get; set; }
        public String fullOrEmpty { get; set; }
    }
}