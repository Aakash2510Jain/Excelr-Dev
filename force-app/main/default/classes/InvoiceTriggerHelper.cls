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
            HandleBusinessException.captureError('InvoiceTriggerHelper', 'Tax Invoice', ex);

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
                        SendforApprovalProcess(inv.Id, financeUserId);
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
            HandleBusinessException.captureError('InvoiceTriggerHelper', 'Tax Invoice', ex);
        }
    }

    public void SendforApprovalProcess(Id objId, Id approverId){
        try{
            Map<Id, Approval.ProcessSubmitRequest> InvoiceToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest(  );
            approvalRequest.setComments('Submitting for Referral Approval');
            approvalRequest.setObjectId(objId);
            approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
            approvalRequest.setNextApproverIds(new List<Id>{ approverId });
            InvoiceToapprovalRequestMap.put(objId, approvalRequest);

            if ( !InvoiceToapprovalRequestMap.isEmpty() ){
                List<Approval.ProcessResult> result = Approval.process( InvoiceToapprovalRequestMap.values() );
            }


        }
        catch ( Exception e ){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CaseTriggerHeper', 'doApproval', e);
        }
    }

    public void sendReferralFormViaEmail(map<id, Invoice__c> InvoiceOldMap, map<id, Invoice__c> InvoiceNewMap){

        set<String> EmailList = new Set<string>();

        try{
            if ( !InvoiceNewMap.isEmpty() ){
                for ( Invoice__c invRec : InvoiceNewMap.values() ){
                    if ( invRec.Approval_Status__c != null && invRec.Approval_Status__c != InvoiceOldMap.get(invRec.id).Approval_Status__c && invRec.Approval_Status__c == 'Approved' ){

                        // list<String> EmialAddresses = new list<String>();
                        // EmialAddresses.add(acc.contacts[0].email);
                        // mail.setToAddresses(EmialAddresses);
                        // mail.setSubject('Upload Document');

                        // String body = 'Dear ' + acc.Contacts[0].Name + ', ' + '<br/><br/>';
                        // body += 'Please ' + '<br/>';
                        // body += '<a href=https://sales-production--fsldemo--c.sandbox.vf.force.com/apex/AccountSummary?id=' + accid + '>Upload Document.</a>' + +'<br/>';
                        // body += 'Thank You';
                        // mail.setHtmlBody(body);

                        // mailList.add(mail);
                        // if ( !mailList.isEmpty() ){
                        //     Messaging.sendEmail(mailList);

                        // }
                    }
                }

            }

        }
        catch ( Exception e ){

        }
    }

}