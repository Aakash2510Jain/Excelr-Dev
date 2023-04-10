global without sharing class BatchForClosureOfTask implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime post24Hours = datetime.now().addDays(-1);
        return Database.getQueryLocator([Select Id,Status From Task where Subject =: Constants.taskSubjectViaLeadCreationAPI and Status = 'Open' And CreatedDate <: post24Hours limit 1000]);
    }
    
    global void execute(Database.BatchableContext bc, List<Task> taskList) {
        if(!taskList.isEmpty()){
            for (Task taskRec : taskList) {
                taskRec.Status = 'Completed';
            }
            update taskList;
        }        
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}