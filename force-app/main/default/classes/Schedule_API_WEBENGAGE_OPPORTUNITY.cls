global class Schedule_API_WEBENGAGE_OPPORTUNITY implements Schedulable {
    global static void execute(SchedulableContext sc){
        API_WEBENGAGE_OPPORTUNITY batchForAPItoPushOpportunity = new API_WEBENGAGE_OPPORTUNITY();
        database.executeBatch(batchForAPItoPushOpportunity, 20);
    }
}