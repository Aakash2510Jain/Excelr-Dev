global class ScheduleBatchFollowupEmailThirtyMinOpp implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        BatchToSendFollowupEmailThirtyMinOpp batchableInstance = new BatchToSendFollowupEmailThirtyMinOpp();
        database.executeBatch(batchableInstance,10);
    }   
}