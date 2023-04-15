global without sharing class BatchOnAccountToUpdatePhone implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,Phone,Alternate_Phone__c FROM Account WHERE Phone !=: null OR Alternate_Phone__c !=: null]);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accountList) {
        List<Account> AccountListToBeUpdated = New List<account>();
       if(!accountList.isEmpty()){

        for(Account accountRecord : accountList){
            if(accountRecord.Phone != null || accountRecord.Alternate_Phone__c != null){
                if(accountRecord.Phone != null){
                    accountRecord.Phone = '+'+accountRecord.Phone;
    
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