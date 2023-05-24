global class ScheduleBatchToSendEmailfifteenMinOnLead implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        BatchToSendEmailForFollowupFromLead batchableInstance = new BatchToSendEmailForFollowupFromLead();
        database.executeBatch(batchableInstance,10);
    }   
}