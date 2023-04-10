public without sharing class RazorpayPaymentLWCController {
    
    @AuraEnabled(cacheable = true)
    public static String sendPaymentLink(String recordId){
        try{
        return RazorpayPaymentHandler.sendPaymentLink(recordId);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
          HandleBusinessException.captureError('RazorpayPaymentLWCController', 'sendPaymentLink', e , null);
           return null;
        }
    }

    @AuraEnabled
    public static void updateOpp(String recordId){
        try{
        Opportunity opp = new Opportunity(Id=recordId,Payment_Initiated__c=true);
        update opp;
        
        Utility.CreateInvoice(recordId);
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RazorpayPaymentLWCController', 'updateOpp', e , null);
        
    }
}
}