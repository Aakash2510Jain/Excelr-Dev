@isTest
public   class TriggerOnCaseTestClass {
    //CaseTriggerHeper clas = new CaseTriggerHeper();
    public static testMethod void upsertcaseRec() {
        
        List<Case> caseLIst = new List<Case>();
        
        
                
        Profile p = [Select Id from Profile where Name = 'System Administrator'];
        User user1 = new User();
        user1.Username = 'usqqqqqqqqqqqqqqqqqqqq1@test.com';
        user1.Email = 'us1@test.com';
        user1.LastName = 'LastName1';
        user1.FirstName = 'FirstName1';
        user1.Alias ='u1';
        user1.CommunityNickname ='use1';
        user1.ProfileId =p.id;
        user1.EmailEncodingKey='UTF-8';
        user1.LanguageLocaleKey='en_US';
        user1.LocaleSidKey='en_US';
        user1.TimeZoneSidKey='America/Los_Angeles';
        user1.Country = 'US';
        user1.Working_Days__c = 'Tuesday';
            user1.Working_Start_Time__c =  Time.newInstance(1, 2, 3, 4);
            user1.Working_End_Time__c =  Time.newInstance(1, 2, 3, 5);
            user1.Start_Date__c = system.today();
            user1.End_Date__c = system.today();
        user1.Title = 'Territory Manager';
        insert user1;
        
        User user2 = new User();
        user2.Username = 'usasasasasasasa2@test.com';
        user2.Email = 'us2@test.com';
        user2.LastName = 'LastName';
        user2.FirstName = 'FirstName2';
        user2.Alias ='u2';
        user2.CommunityNickname ='use2';
        user2.ProfileId =p.id;
        user2.ManagerId = user1.id;
        user2.EmailEncodingKey='UTF-8';
        user2.LanguageLocaleKey='en_US';
        user2.LocaleSidKey='en_US';
        user2.TimeZoneSidKey='America/Los_Angeles';
        user2.Country = 'US';
        user2.Title = 'Field Service Manager';
         user2.Working_Days__c = 'Tuesday';
            user2.Working_Start_Time__c =  Time.newInstance(1, 2, 3, 4);
            user2.Working_End_Time__c =  Time.newInstance(1, 2, 3, 5);
            user2.Start_Date__c = system.today();
            user2.End_Date__c = system.today();
        insert user2;
        
        Case caseRec = new Case();
        //caseRec.Approval_Status__c = 'Approved';
        caseRec.Status = 'On Hold';
        caseRec.Origin = 'Email';
        caseRec.OwnerId = user2.id;
        caseLIst.add(caseRec);
        insert caseLIst;
        
        
        Case caseRec1 = new Case();
        //caseRec1.Approval_Status__c = 'Approved';
        caseRec1.Status = 'On Hold';
        caseRec1.Origin = 'Email';
        caseRec1.OwnerId = user2.id;
        insert caseRec1;
        
        map<id,Case> mapCase = new map<id,Case>();
        mapCase.put(caseRec1.id,caseRec1);

        
        string userId = user1.Id;
        //Account acclist = [Select id,Name From Account Where Id=: userId];
        Account acc = new Account();
        acc.Name = 'Manager';
        acc.OwnerId = userId ;
        insert acc;
        
             Refund__c refundRec = new Refund__c();
        refundRec.Account__c = acc.id;
        insert refundRec;
        
             Bank_Details__c bdRec = new Bank_Details__c();
        bdRec.Account__c = acc.id;
        insert bdRec;
        
        
        
        
        /* test.startTest();
CaseTriggerHeper.onAfterInsert(caseLIst,mapCase);
test.stopTest();*/
        
    }
}