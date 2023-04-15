global without sharing class BatchOnContactToUpdatePhone implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,Phone,Alternate_Phone__c FROM Contact WHERE Phone !=: null OR Alternate_Phone__c !=: null]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> contactList) {
        List<Contact> contactListToBeUpdated = New List<Contact>();
       if(!contactList.isEmpty()){

        for(Contact contactRecord : contactList){
            if(contactRecord.Phone != null || contactRecord.Alternate_Phone__c != null){
                if(contactRecord.Phone != null){
                    contactRecord.Phone = '+'+contactRecord.Phone;
    
                }
                if(contactRecord.Alternate_Phone__c != null){
                    contactRecord.Alternate_Phone__c = '+'+contactRecord.Alternate_Phone__c;
    
                }
                contactListToBeUpdated.add(contactRecord);
            }
        }
        if(!contactListToBeUpdated.isEmpty()){
            update contactListToBeUpdated;
        }
       }        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
}