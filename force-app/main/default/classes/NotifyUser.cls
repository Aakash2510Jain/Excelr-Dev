public without Sharing class  NotifyUser {
    public static void processNotifications(List<task> taskList){
        set<Id> taskIds = new Set<Id>();
        List<Task> insertedTaskList = new List<Task>();
        
        if(!taskList.isEmpty()){
            for(Task taskRec : taskList){
                taskIds.add(taskRec.id);
            }
            if(!taskIds.isEmpty()){
                insertedTaskList = [Select Id,OwnerId FRom Task where id in : taskIds];
                if(!insertedTaskList.isEmpty()){
                    for(task taskRec: insertedTaskList){
                        sendCustomNotification(taskRec.Id, taskRec.OwnerId );
                    }
                }
            }
        }
    }
    
    public static void sendCustomNotification(string recordId, string userId){
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FollowUpTaskReminder'];
        if(notificationType != null){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('New Task Assigned');
            notification.setBody('A new task has been assigned to you. Please review it');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(recordId);
            try {
                system.debug('sending');
                notification.send(new Set<String> {userId});
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }   
            
        }
    }
}