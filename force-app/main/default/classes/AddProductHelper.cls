public class AddProductHelper {
    @auraEnabled
    public static productWrap getAllData(){
        List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        
        prodList = [Select Id,Name,City__c,Mode__c,Type__c From Product2 where isActive = true];
        priceBookEntryList = [select id,UnitPrice,Product2.name,product2.Mode__c,product2.type__c From PricebookEntry where isActive = true];
        
        productWrap productWrapRec = new productWrap(getAllPicklistValues(),prodList,priceBookEntryList);
        return productWrapRec;
    }
    
    
    
    public static Map<String, List<String>> getAllPicklistValues(){
        Map<String, List<String>> picklistValueByFieldName = new Map<String, List<String>>();
        picklistValueByFieldName.put('Type__c',getPickListValuesIntoList('Product2','Type__c'));
        picklistValueByFieldName.put('Mode__c',getPickListValuesIntoList('Product2','Mode__c'));
        
        system.debug('picklistValueByFieldName--->'+ picklistValueByFieldName);
        return picklistValueByFieldName;
    }
    public static List<String> getPickListValuesIntoList(string objectAPIName, string fieldAPIName){
        List<String> pickListValuesList= new List<String>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectAPIName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldAPIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    public class productWrap{
        @auraEnabled
        public Map<String, List<String>> pickValByField;
        @auraEnabled
        public List<Product2> productList;
        @auraEnabled
        public List<PricebookEntry> priceBookEntryList;
        
        public productWrap(Map<String, List<String>> pickValByField, List<Product2> productList, List<PricebookEntry> priceBookEntryList){
            this.pickValByField = pickValByField;
            this.productList = productList;
            this.priceBookEntryList = priceBookEntryList;
        }
    }
}