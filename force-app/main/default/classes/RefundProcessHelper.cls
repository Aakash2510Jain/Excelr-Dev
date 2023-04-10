public without sharing class RefundProcessHelper {
    
    @Auraenabled
    public static string createCase(String oppId){
        try{
            Opportunity oppRec = [SELECT Id, AccountId, Account.Owner.ManagerId FROM Opportunity WHERE Id=: oppId];
            if(oppRec != null){
                List<Case> csListToBeInserted = new List<Case>();
                List<Refund__c> refundListToBeInserted = new List<Refund__c>();
                
                Case newCase = new Case();
                newCase.Case_Type__c = 'Refund';
                newCase.AccountId = oppRec.AccountId;
                newCase.Subject = 'Refund Process Initiated';
                csListToBeInserted.add(newCase);
                
                Refund__c newRefund = new Refund__c();
                newRefund.Account__c = oppRec.AccountId ;
                newRefund.Refund_Status__c = 'Initiated';
                refundListToBeInserted.add(newRefund);
                
                if(!csListToBeInserted.isEmpty() && !refundListToBeInserted.isEmpty()){
                    insert csListToBeInserted;
                    insert refundListToBeInserted;
                }
                if(oppRec.Account.Owner.ManagerId != null){
                    Map<Id, Approval.ProcessSubmitRequest> caseToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitting for Case Severity Approval');
                    approvalRequest.setObjectId(oppRec.AccountId);
                    approvalRequest.setProcessDefinitionNameOrId('Account_Refund_Approval');
                    approvalRequest.setNextApproverIds(new List<Id> {oppRec.Account.Owner.ManagerId});
                    caseToapprovalRequestMap.put(oppRec.AccountId, approvalRequest);
                    
                    if(!caseToapprovalRequestMap.isEmpty())
                        List<Approval.ProcessResult> result = Approval.process(caseToapprovalRequestMap.values());
                    
                }
                return 'Success';
            }
            return '';
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
           HandleBusinessException.captureError('RefundProcessHelper', 'createCase', e, null);
            return 'error';
        }
    }
    
}