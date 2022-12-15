public without sharing class CCAvenueCatchResponse {
    
    @RemoteAction
    public static void updatePaymentStatus(String recordId, String paymentStatus){
        Opportunity opp = new Opportunity(Id=recordId,Payment_Captured__c = paymentStatus=='Success');
        update opp;
    }
}