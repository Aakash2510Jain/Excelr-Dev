public without sharing class ContactTriggerHandler {
    
    static ContactTriggerHandler handlerInstance;
    
    public static ContactTriggerHandler getInstance(){
        if ( handlerInstance == null )
            handlerInstance = new ContactTriggerHandler();
        return handlerInstance;
    }
    
    public void afterCreate(List<Contact> newContactList){
        try{
            system.debug('newContactList -- ' + newContactList);
            
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('afterUpdate','createtaskForIsm', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
}