global class BatchTODeleteCustomer implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id from Customers__c]);
    }
    
    global void execute(Database.BatchableContext bc, List<Customers__c> taskList) {
        if(!taskList.isEmpty()){
            delete taskList;
        }        
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}