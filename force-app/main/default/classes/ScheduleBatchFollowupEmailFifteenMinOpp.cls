global class ScheduleBatchFollowupEmailFifteenMinOpp implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        BatchToSendFollowupEmailFifteenMinOpp batchableInstance = new BatchToSendFollowupEmailFifteenMinOpp();
        database.executeBatch(batchableInstance,10);
    }   
}