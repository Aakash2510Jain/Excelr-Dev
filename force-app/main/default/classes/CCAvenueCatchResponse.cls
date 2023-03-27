public without sharing class CCAvenueCatchResponse {
    
    @RemoteAction
    public static void updatePaymentStatus(String recordId, String paymentStatus){
        try{
        system.debug('recordId--->'+recordId);
        system.debug('paymentStatus---->'+paymentStatus);
        
        Opportunity opp = new Opportunity(Id=recordId,Payment_Captured__c = paymentStatus =='Success');
        update opp;
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CCAvenueCatchResponse', 'updatePaymentStatus', e , null);
       
    }
}
}