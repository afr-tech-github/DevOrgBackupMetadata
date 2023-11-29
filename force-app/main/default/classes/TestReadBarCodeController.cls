public with sharing class TestReadBarCodeController{
    public TestReadBarCodeController(){
        myString = '';
        listString = new List<String>();
   }
   public String myString{get;set;}
   public List<String> listString{get;set;}
   
   public void addToList(){
       if(String.isNotBlank(this.myString)){
           listString.add(myString);
           myString = '';
       }
   }
}