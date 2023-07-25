@IsTest(SeeAllData=true)
public without sharing class RetailInvoiceHelper_Test {
    
     public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static testMethod void getInvoiceRec(){
        Product2 pro = new Product2();
        pro.name = 'test';
        insert pro;
        
        CustomInformation__c cus = new CustomInformation__c();
        cus.Name = 'test';
        insert cus;
        
        CustomInformation__c cd = [Select Name,Address__c,City__c,Pin_Code__c,State_Code__c,GSTIN__c,State_Name__c,EMail__c,Central_GST__c,State_GST__c,HSN_SAC__c,Rate__c from CustomInformation__c Where Id=:cus.Id];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Account acc = new Account(Name='TestAccount');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect', Pricebook2Id=customPB.Id , Expected_Revenue__c = 3000);
        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500);
        insert oli;
        GST_State_Code__c gs = new GST_State_Code__c();
        gs.Name = 'UP';
        gs.State_Code__c = 344;
        insert gs;
        
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

        Invoice_Attachment__e invAtt = new Invoice_Attachment__e();
                invAtt.Invoice__c = invRec.id;
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(invAtt);
            
        Test.stopTest();
        
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(invRec);
        PageReference pageRef2 = Page.RetailInvoice_Attachment;
        pageRef2.getParameters().put('Id', invRec.Id);
        Test.setCurrentPage(pageRef2);
        RetailInvoiceHelper dfT2 = new RetailInvoiceHelper(sc2);
    }
    
    public static testMethod void TestattachPdf(){
        
        
        Account acc = new Account(Name='TestAccount');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect');
        insert opp;
        
        Lead led = new Lead();
        led.lastName = 'test';
        led.Status = 'Open';
        led.Email = 'test@gmail.com';
        led.Company ='util';
        insert led;
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
        invRec.LeadInvoice__c = led.Id;
        insert invRec;
        
        PageReference pdfPage = Page.RetailInvoice_Attachment;
        pdfPage.getParameters().put('id',invRec.id);
        Blob b;
        if(Test.isRunningTest()){
            b = blob.valueOf('Unit.Test');
        }else{
            b = pdfPage.getContentAsPDF();
        }
        List<Attachment> attachList = new List<Attachment>();
        //  Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = invRec.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        attachment.IsPrivate = false;
        attachment.ContentType = 'application/pdf';
        attachList.add(attachment);
        insert attachList;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        RetailInvoiceHelper.attachPdf(invRec.id);
        test.stopTest();
    }
    
}