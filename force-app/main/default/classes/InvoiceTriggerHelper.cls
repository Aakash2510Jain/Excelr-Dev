public class InvoiceTriggerHelper{
    static InvoiceTriggerHelper handlerInstance;
    
    public static InvoiceTriggerHelper getInstance(){
        if ( handlerInstance == null )
            handlerInstance = new InvoiceTriggerHelper();
        return handlerInstance;
    }
    
    public void beforeUpdate(Map<Id, Invoice__c> newMap, Map<Id, Invoice__c> oldMap){
        try{
            set<id> invoiceIds = new set<Id>();
            for ( Invoice__c invoiceRec : newMap.values() ){
                if ( invoiceRec.Status__c != oldMap.get(invoiceRec.Id).Status__c && invoiceRec.Status__c == 'Realized' ){
                    invoiceIds.add(invoiceRec.Id);
                }
            }
            if ( !invoiceIds.isEmpty() ){
                for ( Id invoiceId : invoiceIds ){
                    RetailInvoiceHelper.attachPdf(invoiceId);
                }
            }
        }
        catch ( exception ex ){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
           HandleBusinessException.captureError('InvoiceTriggerHelper', 'Tax Invoice', ex, null);
        }
    }
    
    public void sendforApproval(list<Invoice__c> invoiceList){
        System.debug('invoiceList =====> ' + invoiceList);
        set<id> invoiceIds = new Set<Id>();
        Set<Id> underApprovalCaseSet = new Set<Id>();
        list<task> TaskListTobeCreated = new List<task>();
        try{
            if ( !invoiceList.isEmpty() ){
                for ( invoice__c inv : invoiceList ){
                    if(inv.Type__c == 'Credit Note')
                        invoiceIds.add(inv.Id);
                }
                Id financeUserId = [SELECT Id, Name
                                    FROM User
                                    WHERE Profile.Name = 'Finance'
                                    LIMIT 1].Id;
                
                List<ProcessInstance> recordUnderApprovalList = [Select ID, Status, TargetObjectID, TargetObject.Name
                                                                 From ProcessInstance
                                                                 Where Status = :Constants.PENDING AND TargetObjectID IN:invoiceIds];
                for ( ProcessInstance approvalOpp : recordUnderApprovalList ){
                    underApprovalCaseSet.add(approvalOpp.TargetObjectID);
                }
                
                for ( invoice__c inv : invoiceList ){
                    if ( underApprovalCaseSet.contains(inv.Id) ){
                        inv.addError(Constants.UNDER_APPROVAL_PROCESS_ERR_MSG);
                    }
                    if ( !underApprovalCaseSet.contains(inv.Id) ){
                        SendforApprovalProcess(inv.Id, '005N000000CSOuaIAH');
                    }
                    
                    task tsk = new Task();
                    tsk.Subject = 'Release Credit Note';
                    tsk.Status = 'Open';
                    tsk.Priority = 'Medium';
                    tsk.WhatId = inv.Opportunity__c;
                    tsk.OwnerId = financeUserId;
                    TaskListTobeCreated.add(tsk);
                }
                if ( !TaskListTobeCreated.isEmpty() ){
                    insert TaskListTobeCreated;
                }
            }
            
            
        }
        catch ( Exception ex ){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
            HandleBusinessException.captureError('InvoiceTriggerHelper', 'Tax Invoice', ex, null);
        }
    }
    
    public void SendforApprovalProcess(Id objId, Id approverId){
        try{
            system.debug('objId-->'+objId);
            system.debug('approverId-->'+approverId);
            /* Map<Id, Approval.ProcessSubmitRequest> InvoiceToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest(  );
approvalRequest.setComments('Submitting for Referral Approval');
approvalRequest.setObjectId(objId);
approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
approvalRequest.setNextApproverIds(new List<Id>{ approverId });
InvoiceToapprovalRequestMap.put(objId, approvalRequest);

if ( !InvoiceToapprovalRequestMap.isEmpty() ){
List<Approval.ProcessResult> result = Approval.process( InvoiceToapprovalRequestMap.values() );
}

*/
            // Create an approval request for the Opportunity
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            req1.setObjectId(objId);
            req1.setNextApproverIds(new Id[] {approverId});
            
            // Submit the approval request for the Opportunity
            Approval.ProcessResult result = Approval.process(req1);
            
            
        }
        catch ( Exception e ){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
           HandleBusinessException.captureError('CaseTriggerHeper', 'doApproval', e, null);
        }
    }
    
    public void sendReferralFormViaEmail(map<id, Invoice__c> InvoiceOldMap, map<id, Invoice__c> InvoiceNewMap){
        
        set<String> ReferrarEmailList = new Set<string>();
        map<String, String> ReferrarNameWithEmail = new Map<String,String>();
        map<id,Invoice__c> ApprovedReferrarMap = new map<id,Invoice__c>();
        
        try{
            if ( !InvoiceNewMap.isEmpty() ){
                for ( Invoice__c invRec : InvoiceNewMap.values() ){
                    if ( invRec.Approval_Status__c != null && invRec.Approval_Status__c != InvoiceOldMap.get(invRec.id).Approval_Status__c && invRec.Approval_Status__c == 'Approved' && invRec.Referrer_Email__c != null && invRec.Referral_Name__c != null){
                        //ReferrarNameWithEmail.put(invRec.Referrer_Email__c, invRec.Referral_Name__c);
                        ApprovedReferrarMap.put(invRec.Id, invRec);
                    }
                }
                
                if (!ApprovedReferrarMap.isEmpty()) {
                    //https://excelr2--dev.sandbox.my.salesforce-sites.com/Loginpage/CaptureBankDetails
                    EmailIUtility.SendReferralFormToReferrar(ApprovedReferrarMap);
                }
                
            }
        }
        catch ( Exception e ){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
           HandleBusinessException.captureError('CaseTriggerHeper', 'doApproval', e, null);
            
        }
    }
    
}