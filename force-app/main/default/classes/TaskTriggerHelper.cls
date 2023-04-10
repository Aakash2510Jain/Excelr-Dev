public without sharing class TaskTriggerHelper {
    
    static TaskTriggerHelper handlerInstance;
    
    public static TaskTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new TaskTriggerHelper();
        return handlerInstance;
    }
    
    public void beforeUpdate(Map<Id,Task> newMap, Map<Id, Task> oldMap){
        try{
           
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('TaskTriggerHelper', 'beforeUpdate', e , null);
            
        }
    }
    public void afterInsert(List<Task> newTaskList){
        try{
            NotifyUser.sendCustomNotificationForTask(newTaskList);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('TaskTriggerHelper', 'beforeUpdate', e , null);
            
        }
    }
}