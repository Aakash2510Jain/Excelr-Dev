public without sharing  class AddProductHelper {
    @auraEnabled
    public static productWrap getAllData(){
        try{
        List<Product2> prodList = new List<Product2>();
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
                prodList = [Select Id,Name,City__c,Mode__c,Type__c From Product2 where isActive = true];
        priceBookEntryList = [select id,UnitPrice,Product2.name,product2.Mode__c,product2.type__c From PricebookEntry where isActive = true];
        
        productWrap productWrapRec = new productWrap(getAllPicklistValues(),prodList,priceBookEntryList);
        return productWrapRec;
        }  catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('AGMTriggerHelper', 'Before AGM Update', e, null);
        }
        return null;
    }
    
    
    
    public static Map<String, List<String>> getAllPicklistValues(){
        try{
        Map<String, List<String>> picklistValueByFieldName = new Map<String, List<String>>();
        List<String> classroomCitiesStringList = new List<String>();
        //custom setting
        Map<String, City__c> classroomCitiesMap = City__c.getAll();
        
        if(!classroomCitiesMap.isEmpty()){
            for(String city : classroomCitiesMap.keyset()){
                classroomCitiesStringList.add(city);
            }
        }
        picklistValueByFieldName.put('Type__c',getPickListValuesIntoList('Product2','Type__c'));
        picklistValueByFieldName.put('Mode__c',getPickListValuesIntoList('Product2','Mode__c'));
        picklistValueByFieldName.put('City__c',classroomCitiesStringList);
        system.debug('picklistValueByFieldName--->'+ picklistValueByFieldName);
        return picklistValueByFieldName;
    }  catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
        HandleBusinessException.captureError('AGMTriggerHelper', 'Before AGM Update', e, null);
    }
        return null;
    }
    public static List<String> getPickListValuesIntoList(string objectAPIName, string fieldAPIName){
        try{
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
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
        HandleBusinessException.captureError('AGMTriggerHelper', 'Before AGM Update', e, null);
    }
    return null;
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