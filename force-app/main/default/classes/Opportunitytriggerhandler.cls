public with sharing class Opportunitytriggerhandler{
    static Opportunitytriggerhandler handlerInstance;

    public static Opportunitytriggerhandler getInstance(){
        if ( handlerInstance == null )
            handlerInstance = new Opportunitytriggerhandler();
        return handlerInstance;
    }

    public void createtaskForIsm(map<id, Opportunity> oldOppMap, map<id, Opportunity> newOppMap){
        set<id> accountIds = new set<id>();
        list<account> accountList = new List<Account>();
        list<account> ReferralAccountList = new List<Account>();
        Map<Id, Account> ReferralAccountMap = new Map<id, Account>();
        List<task> TaskListTobeCreated = new List<Task>();
        map<string, Opportunity> AccountIdwithOpportunity = new Map<String, Opportunity>();
        map<id, Opportunity> OppWithReferralAccount = new Map<Id, Opportunity>();

        List<Invoice__c> invoiceListtobeInserted = new List<Invoice__c>();
        try{
            if ( !newOppMap.isEmpty() ){
                for ( Opportunity opp : newOppMap.values() ){
                    if ( opp.StageName != null && opp.StageName == 'Converted' && opp.StageName != oldOppMap.get(opp.id).StageName ){
                        accountIds.add(opp.AccountId);
                        //OppWithReferralAccount.put(opp.id, value)
                        AccountIdwithOpportunity.put(opp.AccountId, opp);
                    }
                }

                if ( !accountIds.isEmpty() ){
                    accountList = [SELECT AccountSource, Approval_Status__c, Email__c, GCLID__c, Id,  Name, OwnerId, Phone, Referral_Email__c, Referral_Phone__c
                                   FROM Account
                                   where Id In:accountIds];
                    if ( !accountList.isEmpty() ){
                        for ( account acc : accountList ){
                            if ( acc.Referral_Email__c != null && acc.Referral_Phone__c != null && acc.OwnerId != null ){
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
                    }
                    if (!invoiceListtobeInserted.isEmpty()) {
                        insert invoiceListtobeInserted;
                    }
                    if ( !TaskListTobeCreated.isEmpty() ){
                        insert TaskListTobeCreated;
                    }
                }
            }

        }
        catch ( Exception e ){
            System.debug('the error has occured due to =====> ' + e.getMessage());
            System.debug('the error has occured at line =====> ' + e.getLineNumber());
            System.debug('error stack trace ======> ' + e.getStackTraceString());
        }
    }

}