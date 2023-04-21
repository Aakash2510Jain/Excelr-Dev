global without sharing class BatchOnAccountToUpdatePhone implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        dateTime todayInstance  =  DateTime.newInstance(2023, 04, 18, 07,00, 00);
        return Database.getQueryLocator([SELECT Id,Name,Phone__c,Alternate_Phone__c FROM Opportunity WHERE (Phone__c !=: null OR Alternate_Phone__c !=: null) And CreatedDate = today AND CreatedDate <: todayInstance]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> accountList) {
        List<Opportunity> AccountListToBeUpdated = New List<Opportunity>();
       if(!accountList.isEmpty()){

        for(Opportunity accountRecord : accountList){
            if(accountRecord.Phone__c != null || accountRecord.Alternate_Phone__c != null){
                if(accountRecord.Phone__c != null){
                    accountRecord.Phone__c = '+'+accountRecord.Phone__c;
    
                }if(accountRecord.Alternate_Phone__c != null){
                    accountRecord.Alternate_Phone__c = '+'+accountRecord.Alternate_Phone__c;
    
                }
                AccountListToBeUpdated.add(accountRecord);
            }
        }
        if(!AccountListToBeUpdated.isEmpty()){
            update AccountListToBeUpdated;
        }
       }        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
}