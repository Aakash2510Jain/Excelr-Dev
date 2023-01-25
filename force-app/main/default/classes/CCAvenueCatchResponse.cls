public without sharing class CCAvenueCatchResponse {
    
    @RemoteAction
    public static void updatePaymentStatus(String recordId, String paymentStatus){
        system.debug('recordId--->'+recordId);
        system.debug('paymentStatus---->'+paymentStatus);
        
        Opportunity opp = new Opportunity(Id=recordId,Payment_Captured__c = paymentStatus=='Success');
        update opp;
    }
}