@IsTest(SeeAllData=true)
public class ContentDocumentLinkTrigger_Test {
    public static testMethod void TestonAfterInsert(){
        
        Account acc = new Account(Name='TestAccount');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity',Payment_Type__c = 'Cash', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect');
        insert opp;
        
        Invoice__c invRec = new Invoice__c();
        invRec.Opportunity__c =  opp.Id ;
        invRec.Delivery_Note__c = 'test';
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = 2000;
        invRec.Type__c = 'Credit Note';
        invRec.Mode_Terms_of_Payment__c = 'Online';
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today().addDays(3);
        invRec.Reference_No__c = '478974';
        invRec.Other_References__c = 'jlkjdlkdj';
        insert invRec;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=invRec.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        cdlList.add(contentlink);
        test.startTest();
        ContentDocumentLinkTrigger handlerInstance = ContentDocumentLinkTrigger.getInstance();
        handlerInstance.onAfterInsert(cdlList);
        test.stopTest();
    }
}