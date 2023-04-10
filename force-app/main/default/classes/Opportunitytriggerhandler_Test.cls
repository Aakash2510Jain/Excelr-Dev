@isTest
public class Opportunitytriggerhandler_Test {
    Public static  testMethod void testOnOpportunity(){
        Account acc = new Account(Name='test',Referral_Email__c = 'dinesh@gmail.com',Referral_Phone__c = '1234567890',OwnerId = UserInfo.getUserId());
        insert acc;
        
        
        string ownerId = acc.OwnerId;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.StageName = 'Prospect';
        opp.CloseDate = System.today();
        opp.Name  = 'test';
        insert opp;
        map<id, Opportunity> oldOppMap = new map<id, Opportunity>();
        oldOppMap.put(opp.Id,opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.StageName = 'Converted';
        opp1.CloseDate = System.today();
        opp1.Name  = 'test';
        insert opp1;
        
        map<id, Opportunity> newOppMap = new  map<id, Opportunity>();
        newOppMap.put(opp1.Id, opp1);
        Invoice__c invRec = new Invoice__c();
        invRec.Opportunity__c = opp1.Id;
        invRec.OwnerId = ownerId;
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = 2000;
        invRec.Type__c = 'Credit Note';
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today().addDays(3);         
        insert invRec;
        
        test.startTest();
        Opportunitytriggerhandler handlerInstance = Opportunitytriggerhandler.getInstance();
       // handlerInstance.createtaskForIsm(oldOppMap, newOppMap);
        test.stopTest();
    }
}