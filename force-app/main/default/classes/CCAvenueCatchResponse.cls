public without sharing class CCAvenueCatchResponse {
    
    @RemoteAction
    public static void updatePaymentStatus(String recordId, String paymentStatus){
        try{
            system.debug('recordId--->'+recordId);
            system.debug('paymentStatus---->'+paymentStatus);
            
          /*  Opportunity opp = new Opportunity(Id=recordId, Payment_Captured__c = paymentStatus =='Success');
            update opp;
            */
            if(paymentStatus =='Success'){
                Receipt_Approval__e receiptApprovalRecord = new Receipt_Approval__e();
                receiptApprovalRecord.Opportunity_Id__c = recordId;
                Database.SaveResult results = EventBus.publish(receiptApprovalRecord);
                if (results.isSuccess()){
                    System.debug('Successfully published event.');
                } 
                else{
                    for (Database.Error err : results.getErrors()){
                        System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                    }
                }
            }
            
        }catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CCAvenueCatchResponse', 'updatePaymentStatus', e , null);
            
        }
    }
}