global without sharing class BatchOnLeadToUpdatePhone implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,Phone,Alternate_Phone__c FROM Lead WHERE Phone !=: null OR Alternate_Phone__c !=: null]);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> LeadList) {
        List<Lead> LeadListToBeUpdated = New List<Lead>();
       if(!LeadList.isEmpty()){

        for(Lead LeadRecord : LeadList){
            if(LeadRecord.Phone != null || LeadRecord.Alternate_Phone__c != null){
                if(LeadRecord.Phone != null){
                    LeadRecord.Phone = '+'+LeadRecord.Phone;
    
                }
                if(LeadRecord.Alternate_Phone__c != null){
                    LeadRecord.Alternate_Phone__c = '+'+LeadRecord.Alternate_Phone__c;
                }
                LeadListToBeUpdated.add(LeadRecord);
            }
        }
        if(!LeadListToBeUpdated.isEmpty()){
            update LeadListToBeUpdated;
        }
       }        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
}