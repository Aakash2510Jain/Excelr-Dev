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
                //notification.send(new Set<String> {userId});
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }   
            
        }
    }
    public static void sendCustomNotificationForApplication(List<Application__c> newApplicationList){      
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='NewApplicationCreated'];
        
        for(Application__c applicationRec : newApplicationList){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('New Application Created');
            notification.setBody('A new Application has been Created. Please review it');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(applicationRec.Id);
            try {
                string usersToNotify = '';
                if(applicationRec.Opportunity__c != null){
                    notification.send(new Set<String> {applicationRec.OwnerId}); //Opportunity__r
                }else if(applicationRec.Account__c != null){
                    notification.send(new Set<String> {applicationRec.OwnerId}); //Account__r
                }else if(applicationRec.Lead__c != null){
                    notification.send(new Set<String> {applicationRec.OwnerId}); //Lead__r
                }
            }
            catch (Exception e) {
                System.debug('Problem sending notification while creating Notification: ' + e.getMessage());
            }   
        }
    }
    public static void sendCustomNotificationForTask(List<Task> newTaskList){
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='CustomerAppliedAgain'];
        
        for(Task taskRec : newTaskList){
            if(taskRec.Subject == Constants.TASKSUBJECTCANDIDATEAPPLIEDAGAIN){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('New Task Assigned');
                notification.setBody('A new task has been assigned to you. Please review it');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(taskRec.Id);
                try {
                    string usersToNotify = '';
                    if(taskRec.OwnerId != null){
                        notification.send(new Set<String> {taskRec.OwnerId});
                    }
                }
                catch (Exception e) {
                    System.debug('Problem sending notification while creating Notification: ' + e.getMessage());
                } 
            }
        }
    }
}