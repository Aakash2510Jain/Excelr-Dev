global without sharing class BatchOnCustomerToUpdatePhone implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,Phone__c,Alternate_Phone__c FROM Customers__c WHERE Phone__c !=: null OR Alternate_Phone__c !=: null]);
    }
    
    global void execute(Database.BatchableContext bc, List<Customers__c> customerList) {
        List<Customers__c> customerListToBeUpdated = New List<Customers__c>();
       if(!customerList.isEmpty()){

        for(Customers__c customerRecord : customerList){
            if(customerRecord.Phone__c != null || customerRecord.Alternate_Phone__c != null){
                if(customerRecord.Phone__c != null){
                    customerRecord.Phone__c = '+'+customerRecord.Phone__c;
    
                }else if(customerRecord.Alternate_Phone__c != null){
                    customerRecord.Alternate_Phone__c = '+'+customerRecord.Alternate_Phone__c;
                    
                }
                customerListToBeUpdated.add(customerRecord);
            }
        }
        if(!customerListToBeUpdated.isEmpty()){
            update customerListToBeUpdated;
        }
       }        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }

}