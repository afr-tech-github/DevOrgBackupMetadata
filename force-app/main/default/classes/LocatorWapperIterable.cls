global with sharing class LocatorWapperIterable implements Iterator<List<LocatorWapper>> {
    List<LocatorWapper> InnerList{get; set;}
    List<LocatorWapper> ListRequested{get; set;}
    Integer i {get; set;} 
    global Integer pageSize {get; set;} 
    
    public LocatorWapperIterable(List<LocatorWapper> lstAccWr) {
        InnerList = new List<LocatorWapper >(); 
        ListRequested = new List<LocatorWapper >();     
        InnerList = lstAccWr;
        pageSize = 10;
        i = 0; 
    }

    global void setPageSize( Integer argPageSize){

    	pageSize = argPageSize;
    	i = 0;
    	//ListRequested = next();
    }
    global Integer pageNumber{
        get{
            pageNumber = 1;
            
            if(Math.mod(i, pageSize) > 0){
                
                pageNumber = i/pageSize + 1; 
            }else{
                pageNumber = i/pageSize;
            }
            return pageNumber;
        }
        set{
            i = 0;
        }
    }
    global Integer totalPage{
        get{
            if(Math.mod(InnerList.size(), pageSize) > 0){
                
                totalPage = InnerList.size()/pageSize + 1; 
            }else{
                totalPage = InnerList.size()/pageSize ;
            }
            return totalPage;
        }
        set;
    }
    global boolean hasNext(){ 

        if(i >= InnerList.size()) {
            return false; 
        } else {
            return true; 
        }
    } 
    
    global boolean hasPrevious(){ 
        if(i <= pageSize) {
            return false; 
        } else {
            return true; 
        }
    }   
    
    global List<LocatorWapper > next(){ 
        ListRequested = new List<LocatorWapper >(); 
        integer startNumber;
        integer size = InnerList.size();
        if(hasNext())
        {  
            if(size <= (i + pageSize))
            {
                startNumber = i;
                i = size;
            }
            else
            {
                i = (i + pageSize);
                startNumber = (i - pageSize);
            }
            
            for(integer start = startNumber; start < i; start++)
            {
                ListRequested.add(InnerList[start]);
            }
        } 
        return ListRequested;
    } 
    
    global List<LocatorWapper> previous(){      
        ListRequested = new List<LocatorWapper>(); 
        integer size = InnerList.size(); 
        if(i == size)
        {
            if(math.mod(size, pageSize) > 0)
            {    
                i = size - math.mod(size, pageSize);
            }
            else
            {
                i = (size - pageSize);
            } 
        }
        else
        {
            i = (i - pageSize);
        }
        
        for(integer start = (i - pageSize); start < i; ++start)
        {
            ListRequested.add(InnerList[start]);
        } 
        return ListRequested;
    }   
}