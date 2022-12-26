public class ContentDocumentLinkTrigger {
    
    static ContentDocumentLinkTrigger handlerInstance;
    public static ContentDocumentLinkTrigger getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new ContentDocumentLinkTrigger();
        return handlerInstance;
    }
    
    public void onAfterInsert(List<ContentDocumentLink> cdlList) {
        try{
            Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Set<ID> parentIds = new Set<ID>();
            
            for ( ContentDocumentLink cdl : cdlList ) {
                parentIds.add( cdl.LinkedEntityId );
            }
            List<Invoice__c> invList = [SELECT Id, LeadInvoice__c, LeadInvoice__r.Payment_Type__c, Opportunity__c, Opportunity__r.Owner.managerid, Lead_ManagerId__c, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Invoice__c WHERE Id IN :parentIds];
            system.debug('invList :: ' + invList);
            for (Invoice__c iRec : invList) {
                if(iRec.LeadInvoice__r.Payment_Type__c == 'Cash' || iRec.LeadInvoice__r.Payment_Type__c == 'Cheque' || iRec.LeadInvoice__r.Payment_Type__c == 'POS'){
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitting for Manager Approval');
                    approvalRequest.setObjectId(iRec.Id);
                    approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
                    if(iRec.LeadInvoice__c != null && iRec.Lead_ManagerId__c != null){
                        approvalRequest.setNextApproverIds(new List<Id> {iRec.Lead_ManagerId__c});
                    }
                    else if((iRec.Opportunity__c != null && iRec.Opportunity__r.Owner.managerid != null) || iRec.Lead_ManagerId__c == null ){
                        approvalRequest.setNextApproverIds(new List<Id> {iRec.Opportunity__r.Owner.managerid});                        
                    }
                    cdToapprovalRequestMap.put(iRec.Id, approvalRequest);
                    
                    if(!cdToapprovalRequestMap.isEmpty())
                        List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                }
            }
        }
        catch (Exception e){
            system.debug('Error :: ' + e.getMessage() + 'At Line Number :: ' + e.getLineNumber());
        }
    }
}