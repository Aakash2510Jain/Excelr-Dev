public without sharing class ApplicationTriggerHelper {
    static ApplicationTriggerHelper handlerInstance;
    
    public static ApplicationTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new ApplicationTriggerHelper();
        return handlerInstance;
    }
    
    
    public void afterInsert(List<Application__c> applicationList){
        try{
            NotifyUser.sendCustomNotificationForApplication(applicationList);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
          HandleBusinessException.captureError('LeadTriggerHandler', 'Before Lead Insert', e , null);
        }
    }
}