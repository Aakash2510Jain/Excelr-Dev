@isTest
public   class CaseTriggerHeperTest {
    //CaseTriggerHeper clas = new CaseTriggerHeper();
    public static testMethod void upsertcaseRec() {
        try{
        List<Case> caseLIst = new List<Case>();
        
        Case caseRec = new Case();
        //caseRec.Approval_Status__c = 'Approved';
        caseRec.Status = 'On Hold';
        caseRec.Origin = 'Email';
        caseRec.Severity__c = 'L2';
        caseLIst.add(caseRec);
        insert caseLIst;
        map<id,Case> mapCase = new map<id,Case>();
        mapCase.put(caseRec.id,caseRec);
        
        test.startTest();
        CaseTriggerHeper casetrigger = new CaseTriggerHeper();
        casetrigger.onAfterInsert(caseLIst,mapCase);
        test.stopTest();
        
        
        /*Case caseRec1 = new Case();
        caseRec1.Approval_Status__c = 'Approved';
        caseRec1.Status = 'On Hold';
        caseRec1.Origin = 'Email';
        insert caseRec1;*/
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CaseTriggerHeperTest', 'upsertcaseRec', e , null);
       
    }
 }
       public static testMethod void upsertcaseRec1(){
        try{
        Profile p = [Select Id from Profile where Name = 'Inside Sales Manager'];
        User user1 = new User();
        user1.Username = 'us1@test.com';
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
        user1.Title = 'Territory Manager';
        user1.Working_Days__c ='Monday';
        user1.Working_End_Time__c = time.newInstance(5, 30, 3, 3);
        user1.Working_Start_Time__c = time.newInstance(12, 30, 3, 3);
        user1.Start_Date__c = system.today();
        user1.End_Date__c = system.today(); 
        insert user1;
        
        Profile p1 = [Select Id from Profile where Name = 'Senior Inside Sales Manager'];   
        User user2 = new User();
        user2.Username = 'us2@test.com';
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
        user2.Working_Days__c ='Monday';
        user2.Working_End_Time__c =time.newInstance(5, 30, 3, 3); 
        user2.Working_Start_Time__c = time.newInstance(12, 30, 3, 3); 
        user2.Start_Date__c = system.today(); 
        user2.End_Date__c = system.today();   
        insert user2;
        
        string userId = user2.Id;
        //Account acclist = [Select id,Name From Account Where Id=: userId];
        Account acc = new Account();
        acc.Name = 'Manager';
        acc.OwnerId = userId ;
        insert acc;
        
        list<Case> caselist = new list<Case>();
        Case cs = new Case();
        cs.OwnerId = user1.id;
        cs.Severity__c = 'L1';
        cs.AccountId = acc.id;
        //caselist.add(cs);
        insert cs;
           cs.Severity__c = 'L2';
           update cs;
           cs.Severity__c = 'L3';
           update cs;
           cs.Severity__c = 'L1';
           update cs;
          
           
           
        map<id,Case> mapCase1 = new map<id,Case>();
        for(Case cs1 : caselist){
             mapCase1.put(cs1.id,cs1);
           }
        
            
        test.startTest();
        CaseTriggerHeper casetrigger = new CaseTriggerHeper();
        casetrigger.onAfterUpdate(caselist,mapCase1);
        test.stopTest();
        
       /* list<Refund__c> refunReclist = new list<Refund__C>{[Select id,Name,Account__c from Refund__c where Account__c =: acc.id]};        
            Refund__c refundRec = new Refund__c();
        refundRec.Account__c = acc.id;
        insert refundRec;
        
        list<Bank_Details__c> bdlist = new list<Bank_Details__c>{[Select id,Name,Account__c  From Bank_Details__c where Account__c =:acc.id]};
            Bank_Details__c bdRec = new Bank_Details__c();
        bdRec.Account__c = acc.id;
        insert bdRec;*/
        
        
            }catch (Exception e){
                system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
              HandleBusinessException.captureError('CaseTriggerHeperTest', 'upsertcaseRec1', e , null);
               
            }

        }
         
    }