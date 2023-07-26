public without sharing class Opportunitytriggerhandler{
    static Opportunitytriggerhandler handlerInstance;
    
    public static Opportunitytriggerhandler getInstance(){
        if ( handlerInstance == null )
            handlerInstance = new Opportunitytriggerhandler();
        return handlerInstance;
    }
    
    public void afterUpdate(map<id, Opportunity> oldOppMap, map<id, Opportunity> newOppMap){
        set<id> accountIds = new set<id>();
        set<id> invoiceIds = new set<id>();
        list<account> accountList = new List<Account>();
        list<account> ReferralAccountList = new List<Account>();
        List<task> TaskListTobeCreated = new List<Task>();
        List<Invoice__c> invoiceListtobeInserted = new List<Invoice__c>();
        Map<Id, Account> ReferralAccountMap = new Map<id, Account>();
        map<string, Opportunity> AccountIdwithOpportunity = new Map<String, Opportunity>();
        
        try{
            if (!newOppMap.isEmpty()){
                for ( Opportunity opp : newOppMap.values() ){
                    System.debug(' opp.StageName  ::'+ opp.StageName);
                    system.debug('oldOppMap.get(opp.Id).StageName--->'+oldOppMap.get(opp.Id).StageName);
                    //accountIds.add(opp.AccountId);
                    if(opp.StageName != oldOppMap.get(opp.Id).StageName && opp.StageName != null && opp.StageName == 'Closed-Won')
                        invoiceIds.add(opp.Latest_Invoice_Id__c);
                    //AccountIdwithOpportunity.put(opp.AccountId, opp);
                }
                if (!accountIds.isEmpty() ){
                    accountList = [SELECT AccountSource, Approval_Status__c, Email__c, GCLID__c, Id,  Name, OwnerId, Phone, Referral_Email__c, Referral_Phone__c FROM Account where Id In:accountIds];
                    if (!accountList.isEmpty() ){
                        for ( account acc : accountList ){
                            if (acc.Referral_Email__c != null && acc.Referral_Phone__c != null && acc.OwnerId != null ){
                                ReferralAccountList.add(acc);
                                ReferralAccountMap.put(acc.id, acc);
                                if ( AccountIdwithOpportunity.containsKey(acc.Id) ){
                                    Invoice__c invRec = new Invoice__c();
                                    invRec.Opportunity__c = AccountIdwithOpportunity.get(acc.Id).Id;
                                    invRec.OwnerId = AccountIdwithOpportunity.get(acc.Id).OwnerId;
                                    invRec.Status__c = 'Initiated';
                                    invRec.Amount__c = 2000;
                                    invRec.Type__c = 'Credit Note';
                                    invRec.Initiated_Date__c = System.Today();
                                    invRec.Invoice_Due_Date__c = System.Today().addDays(3);
                                    invoiceListtobeInserted.add(invRec);
                                }
                            }
                        }
                        if (!invoiceListtobeInserted.isEmpty()) {
                            insert invoiceListtobeInserted;
                        }
                        if ( !ReferralAccountMap.isEmpty() ){
                            for ( account AccRec : ReferralAccountMap.values() ){
                                task tsk = new Task();
                                tsk.Subject = 'Release Credit Note';
                                tsk.Status = 'Open';
                                tsk.Priority = 'Medium';
                                tsk.WhatId = AccRec.Id;
                                tsk.OwnerId = AccRec.OwnerId;
                                TaskListTobeCreated.add(tsk);
                            }
                            if ( !TaskListTobeCreated.isEmpty() ){
                                insert TaskListTobeCreated;
                            }
                        }                        
                    }
                }
                system.debug('invoiceIds--->'+invoiceIds);
                if(!invoiceIds.isEmpty()){
                    //EmailIUtility.sendEmailWithReceiptAndInvoice(invoiceIds,'InvoicePlusReceiptTemplate');
                }
            }
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('afterUpdate','createtaskForIsm', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
    public void beforeupdate(map<id, Opportunity> oldOppMap, map<id, Opportunity> newOppMap){
        
        try {
            for (Opportunity Opp : newOppMap.values()) {
                if (opp.StageName != oldOppMap.get(opp.Id).StageName && (opp.StageName == Constants.OPP_STAGENAME_PROSPECT || opp.StageName == Constants.OPP_STAGENAME_HOT || opp.StageName == Constants.OPP_STAGENAME_AWAITING_CONFIRMATION)) {
                    dateTime postOneMonth = system.now().addMonths(1);
                    if(opp.Next_follow_up_date_time__c > postOneMonth ){
                        string errormessage= 'Follow up date should be less than 1 month to park it in ' + opp.StageName + ' Stage';
                        Opp.Next_follow_up_date_time__c.addError(errormessage);
                    }if (opp.Next_follow_up_date_time__c == null) {
                        Opp.Next_follow_up_date_time__c.addError('Please Fill Next Followup date!!');
                    }
                }
                if (opp.StageName != oldOppMap.get(opp.Id).StageName && opp.StageName == Constants.OPP_STAGENAME_ON_HOLD) {
                    dateTime currentDateTime = system.now();
                    dateTime postOneMonth = system.now().addMonths(1);
                    dateTime postThreeMonth = system.now().addMonths(3);
                    if(opp.Next_follow_up_date_time__c < postOneMonth || Opp.Next_follow_up_date_time__c > postThreeMonth){
                        Opp.Next_follow_up_date_time__c.addError('Follow up date should be greater than 1 month & less than 3 month to park it in On Hold Stage');
                    }
                }
                if(opp.StageName != oldOppMap.get(Opp.Id).StageName && (Opp.StageName ==  Constants.OPP_STAGENAME_DEFERRED) ){
                    dateTime currentDateTime = system.now();
                    dateTime postThreeMonth = system.now().addMonths(3);
                    dateTime postsixMonth = system.now().addMonths(6);
                    if(opp.Next_follow_up_date_time__c < postThreeMonth || opp.Next_follow_up_date_time__c > postsixMonth){
                        opp.Next_follow_up_date_time__c.addError('Follow up date should be greater than 3 month and less than 6 month to park it in Deferred Stage');
                    }
                }
                if(opp.StageName != oldOppMap.get(Opp.Id).StageName || opp.Next_follow_up_date_time__c != oldOppMap.get(Opp.Id).Next_follow_up_date_time__c){
                    dateTime currentDateTime = system.now();
                    if(opp.Next_follow_up_date_time__c == null ){
                        opp.Next_follow_up_date_time__c.addError('Followup Datetime cannot be Empty!!!');
                    }
                    if( opp.Next_follow_up_date_time__c < currentDateTime ){
                        opp.Next_follow_up_date_time__c.addError('Change the Followup Date to Future');
                    }
                }
                if (opp.StageName != oldOppMap.get(Opp.Id).StageName && opp.StageName != null && opp.StageName == Constants.OPP_STAGENAME_CLOSE_LOST) {
                    if (opp.Loss_Reason__c == null) {
                        opp.Loss_Reason__c.addError('Please Specify reason for Loss!!!');
                    }
                    
                }
                if(opp.Alternate_Email__c != oldOppMap.get(Opp.Id).Alternate_Email__c && opp.Alternate_Email__c == null){
                   // opp.Alternate_Email__c.addError('Alternate Email cannot be Empty.');
                }
                if(opp.Email__c != oldOppMap.get(Opp.Id).Email__c && opp.Email__c == null){
                   // opp.Email__c.addError('Email cannot be Empty.');
                } 
                if(opp.Phone__c != oldOppMap.get(Opp.Id).Phone__c && opp.Phone__c == null){
                    //opp.Phone__c.addError('Phone cannot be Empty.');
                }
                if(opp.Alternate_Phone__c != oldOppMap.get(Opp.Id).Alternate_Phone__c && opp.Alternate_Phone__c == null){
                   // opp.Alternate_Phone__c.addError('Alternate Phone cannot be Empty.');
                }
                if(opp.Alternate_Email__c != oldOppMap.get(Opp.Id).Alternate_Email__c && opp.Alternate_Email__c != null){
                    List<Opportunity> OpportunityList = [Select Id From Opportunity where Email__c =:opp.Alternate_Email__c or Alternate_Email__c =:opp.Alternate_Email__c limit 1];
                    List<Lead> leadList = [Select Id From Lead where (Email =: opp.Alternate_Email__c or Alternate_Email__c =:opp.Alternate_Email__c) and isConverted = false limit 1];
                    if(!OpportunityList.isEmpty()){
                        opp.Alternate_Email__c.addError('Duplicate Email Found on Opportunity.');
                    }
                    if(!leadList.isEmpty()){
                        opp.Alternate_Email__c.addError('Duplicate Email Found on Lead.');
                    }
                }
                if(opp.Email__c != oldOppMap.get(Opp.Id).Email__c && opp.Email__c != null){
                    List<Opportunity> OpportunityList = [Select Id From Opportunity where Email__c =:opp.Email__c or Alternate_Email__c =:opp.Email__c limit 1];
                    List<Lead> leadList = [Select Id From Lead where (Email =: opp.Email__c or Alternate_Email__c =:opp.Email__c) and isConverted = false limit 1];
                    if(!OpportunityList.isEmpty()){
                        opp.Email__c.addError('Duplicate Email Found on Opportunity.');
                    }
                    if(!leadList.isEmpty()){
                        opp.Email__c.addError('Duplicate Email Found on Lead.');
                    }
                }
                if(opp.Phone__c != oldOppMap.get(Opp.Id).Phone__c && opp.Phone__c != null){
                    List<Opportunity> OpportunityList = [Select Id From Opportunity where Phone__c =:opp.Phone__c or Alternate_Phone__c =:opp.Phone__c limit 1];
                    List<Lead> leadList = [Select Id From Lead where (Phone =:opp.Phone__c or Alternate_Phone__c =:opp.Phone__c) and isConverted = false limit 1];
                    if(!OpportunityList.isEmpty()){
                        opp.Phone__c.addError('Duplicate Phone Found on Opportunity.');
                    }
                    if(!leadList.isEmpty()){
                        system.debug('leadList--->'+leadList);
                        opp.Phone__c.addError('Duplicate Phone Found on Lead.');
                    }
                }
                if(opp.Alternate_Phone__c != oldOppMap.get(Opp.Id).Alternate_Phone__c && opp.Alternate_Phone__c != null){
                    List<Opportunity> OpportunityList = [Select Id From Opportunity where (Phone__c =:opp.Alternate_Phone__c or Alternate_Phone__c =:opp.Alternate_Phone__c)  limit 1];
                    List<Lead> leadList = [Select Id From Lead where (Phone =:opp.Alternate_Phone__c or Alternate_Phone__c =:opp.Alternate_Phone__c) and isConverted = false limit 1];
                    if(!OpportunityList.isEmpty()){
                        opp.Alternate_Phone__c.addError('Duplicate Phone Found on Opportunity.');
                    }
                    if(!leadList.isEmpty()){
                        opp.Alternate_Phone__c.addError('Duplicate Phone Found on Lead.');
                    }
                }
                if(opp.Next_follow_up_date_time__c != oldOppMap.get(Opp.Id).Next_follow_up_date_time__c && opp.Next_follow_up_date_time__c != null){
                    dateTime currentDateTime = system.now();
                    dateTime postOneMonth = system.now().addMonths(1);
                    dateTime postThreeMonth = system.now().addMonths(3);
                    if(opp.Next_follow_up_date_time__c > postOneMonth && Opp.Next_follow_up_date_time__c < postThreeMonth){
                        opp.StageName = Constants.OPP_STAGENAME_ON_HOLD;
                    }
                    if(opp.Next_follow_up_date_time__c > postThreeMonth){
                        opp.StageName = Constants.OPP_STAGENAME_DEFERRED;
                    }
                }
                if (opp.StageName != oldOppMap.get(Opp.Id).StageName && opp.StageName != Null && (opp.StageName == Constants.OPP_STAGENAME_PROSPECT || opp.StageName == Constants.OPP_STAGENAME_HOT || opp.StageName == Constants.LEAD_STATUS_OPEN || opp.StageName == Constants.OPP_STAGENAME_AWAITING_CONFIRMATION) 
                    && (oldOppMap.get(Opp.Id).StageName == Constants.OPP_STAGENAME_ON_HOLD || oldOppMap.get(Opp.Id).StageName == Constants.OPP_STAGENAME_DEFERRED)  ) {
                        dateTime postOneMonth = system.now().addMonths(1);
                        if (opp.Next_follow_up_date_time__c == null) {
                            opp.Next_follow_up_date_time__c.addError('Please Fill Next Follow Up date');
                        }
                        if (opp.Next_follow_up_date_time__c != null && opp.Next_follow_up_date_time__c != oldOppMap.get(Opp.Id).Next_follow_up_date_time__c && opp.Next_follow_up_date_time__c > postOneMonth) {
                            string errormessage = 'Next Follow up date Cannot be greater than 1 month to Park it in ' + opp.StageName + ' Stage';
                            opp.Next_follow_up_date_time__c.addError(errormessage);
                        }
                    }
                if ((opp.StageName != oldOppMap.get(Opp.Id).StageName && opp.StageName != Null && oldOppMap.get(Opp.Id).StageName == Constants.OPP_STAGENAME_CLOSE_LOST )) {
                    dateTime postOneMonth = system.now().addMonths(1);
                    dateTime postthreeMonth = system.now().addMonths(3);
                    dateTime postsixMonth = system.now().addMonths(6);
                    if (opp.StageName == Constants.OPP_STAGENAME_ON_HOLD  ) { 
                        if (opp.Next_follow_up_date_time__c == null) {
                            opp.Next_follow_up_date_time__c.addError('Please Fill Follow up date!!');
                        }
                        if (opp.Next_follow_up_date_time__c != null && opp.Next_follow_up_date_time__c != oldOppMap.get(Opp.Id).Next_follow_up_date_time__c ) {
                            if (opp.Next_follow_up_date_time__c < postOneMonth || opp.Next_follow_up_date_time__c > postthreeMonth) {
                                string errormessage = 'Next Follow up date Cannot be less than 1 month and greater than 3 months to Park it in ' + opp.StageName + ' Stage';
                                opp.Next_follow_up_date_time__c.addError(errormessage);
                            }
                            
                        }
                        
                    }
                    if ( opp.StageName == Constants.OPP_STAGENAME_DEFERRED ) { 
                        if (opp.Next_follow_up_date_time__c == null) {
                            opp.Next_follow_up_date_time__c.addError('Please Fill Follow up date!!');
                        }
                        if (opp.Next_follow_up_date_time__c != null && opp.Next_follow_up_date_time__c != oldOppMap.get(Opp.Id).Next_follow_up_date_time__c ) {
                            if (opp.Next_follow_up_date_time__c < postthreeMonth || opp.Next_follow_up_date_time__c > postsixMonth) {
                                string errormessage = 'Next Follow up date Cannot be less than 3 month and greater than 6 months to Park it in ' + opp.StageName + ' Stage';
                                opp.Next_follow_up_date_time__c.addError(errormessage);
                            }
                            
                        }
                        
                    }
                    if (opp.StageName == Constants.OPP_STAGENAME_HOT || opp.StageName == Constants.OPP_STAGENAME_PROSPECT || opp.StageName == Constants.OPP_STAGENAME_AWAITING_CONFIRMATION) {
                        if (opp.Next_follow_up_date_time__c == null) {
                            opp.Next_follow_up_date_time__c.addError('Please Fill Follow up date!!');
                        }
                        if (opp.Next_follow_up_date_time__c != null && opp.Next_follow_up_date_time__c != oldOppMap.get(Opp.Id).Next_follow_up_date_time__c && opp.Next_follow_up_date_time__c > postOneMonth) {
                            string errormessage = 'Next Follow up date Cannot be greater than 1 month to Park it in ' + opp.StageName + ' Stage';
                            opp.Next_follow_up_date_time__c.addError(errormessage);
                        }
                    }
                }
                if(opp.Expected_Revenue__c == null){
                    //  opp.Expected_Revenue__c.addError('Fill Expected Revenue.');
                }
                if (opp.CloseDate != null && opp.CloseDate != oldOppMap.get(opp.Id).CloseDate ) {
                    dateTime postOneMonth = system.now().addMonths(1);
                    if (opp.CloseDate > postOneMonth) {
                        opp.CloseDate.addError('Close Date cannot be greater than 30 days!');                   
                    }
                }
              if (opp.StageName != null && opp.StageName != oldOppMap.get(opp.Id).StageName && opp.StageName == 'Closed-Won') {
                    if (opp.Closed_Won_Date_Time__c == null) {
                        opp.Closed_Won_Date_Time__c = system.now();
                    }
                }
            }
            
        } catch (Exception e) {
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('Opportunitytriggerhandler', 'beforeupdate', e, null);
            
        }
    }
    
}