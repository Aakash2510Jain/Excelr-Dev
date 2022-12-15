public class TaskTriggerHelper {
    public static void beforeUpdate(Map<Id,Task> newMap, Map<Id, Task> oldMap){
        for(Task taskRec : newMap.values()){
            if(taskRec.CallObject != null){
                if(taskRec.Updated_Time__c == null)
                    taskRec.Updated_Time__c =0;
                taskRec.Updated_Time__c += 1; 
            }
        }
    }
}