global without sharing class BatchOnOpportunityToUpdatePhone implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,Phone__c,Alternate_Phone__c FROM Opportunity WHERE Phone__c !=: null OR Alternate_Phone__c !=: null]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> opportunityList) {
        List<Opportunity> opportunityListToBeUpdated = New List<Opportunity>();
       if(!opportunityList.isEmpty()){

        for(Opportunity opportunityRecord : opportunityList){
            if(opportunityRecord.Phone__c != null || opportunityRecord.Alternate_Phone__c != null){
                if(opportunityRecord.Phone__c != null){
                    opportunityRecord.Phone__c = '+'+opportunityRecord.Phone__c;
    
                }else if(opportunityRecord.Alternate_Phone__c != null){
                    opportunityRecord.Alternate_Phone__c = '+'+opportunityRecord.Alternate_Phone__c;
    
                }
                opportunityListToBeUpdated.add(opportunityRecord); 
            }
        }
        if(!opportunityListToBeUpdated.isEmpty()){
            update opportunityListToBeUpdated;
        }
       }        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
}