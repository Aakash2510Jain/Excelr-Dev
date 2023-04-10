public without sharing class CreatePaymentOnOppHelper {
    @auraEnabled
    public static void updatePaymentStatus(String oppId){
        try{
        if(!string.isBlank(oppId)){
            Opportunity oppRec = new Opportunity();
            oppRec.Id = oppId;
            oppRec.Payment_Status__c = 'Initiated';
            update oppRec;
        }
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CreatePaymentOnOppHelper', 'updatePaymentStatus', e , null);
       
    }
}
}