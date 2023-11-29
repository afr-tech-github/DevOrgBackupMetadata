public class WorkProgressItemWrapper {
    public String id {get; set;}
    public String status {get; set;}
    public String listingURL {get; set;}
    public String creatingURL {get; set;}
    public String caption {get; set;}
    public String iconURL {get; set;}
    public Boolean hasSubFlow {get; set;}
    public List<WorkProgressItemWrapper> subFlowItems {get; set;}
    
    public WorkProgressItemWrapper(final String id
                                   , final String status
                                   , final String listingURL
                                   , final String caption
                                   ,final String iconURL
                                   , final String creatingURL) {
        this.id = id;
        this.status = status;
        this.listingURL = listingURL;
        this.creatingURL = creatingURL;
        this.caption = caption;
        this.iconURL = iconURL;
        this.hasSubFlow = false;
        this.subFlowItems = new List<WorkProgressItemWrapper>();
    }
}