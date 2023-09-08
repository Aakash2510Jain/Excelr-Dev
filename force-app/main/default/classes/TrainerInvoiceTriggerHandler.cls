public without sharing class TrainerInvoiceTriggerHandler {
    
    static TrainerInvoiceTriggerHandler handlerInstance;
    
    public static TrainerInvoiceTriggerHandler getInstance(){
        if ( handlerInstance == null )
            handlerInstance = new TrainerInvoiceTriggerHandler();
        return handlerInstance;
    }
    
    public void afterUpdate(List<Trainer_Invoice__c> newTrainerInvoiceList, Map<Id, Trainer_Invoice__c> oldTrainerInvoiceMap){
        try{
            system.debug('newTrainerInvoiceList -- ' + newTrainerInvoiceList);
            set<Id> tInvIdSet = new set<Id>();
            for(Trainer_Invoice__c tInvRec : newTrainerInvoiceList){
                if(oldTrainerInvoiceMap.get(tInvRec.Id).Status__c != tInvRec.Status__c && tInvRec.Status__c != null && !String.isBlank(tInvRec.Status__c)){
                    tInvIdSet.add(tInvRec.Id);
                }
            }
            system.debug('tInvIdSet -- ' + tInvIdSet);
            if(tInvIdSet.size()>0){
                //callStatusUpdateAPI(tInvIdSet);
            }
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('TrainerInvoiceTriggerHandler','afterUpdate', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
    @future(callout=true)
    public static void callStatusUpdateAPI(set<Id> tInvIdSet){
        LMS_ApiCallouts.doInvoiceStatusUpdate(tInvIdSet);
    }
    
    
}