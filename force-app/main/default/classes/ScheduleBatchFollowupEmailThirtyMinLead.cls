global class ScheduleBatchFollowupEmailThirtyMinLead implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        BatchToSendFollowupEmailThirtyMinLead batchableInstance = new BatchToSendFollowupEmailThirtyMinLead();
        database.executeBatch(batchableInstance,10);
    }   
}