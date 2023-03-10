@isTest
public class RetailInvoiceHelper_Test {
    public static testMethod void getInvoiceRec(){
         Account acc = new Account();
        acc.Name = 'Aakash';
        insert acc;
        
        Opportunity oppRec = new Opportunity();
        oppRec.Name = 'OppTest';
        oppRec.AccountId = acc.id;
        oppRec.StageName = 'Prospect';
        oppRec.CloseDate = system.today();
        insert oppRec;
        
         Invoice__c invRec = new Invoice__c();
        invRec.Opportunity__c =  oppRec.Id ;
        invRec.OwnerId =  acc.Id ;
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = 2000;
        invRec.Type__c = 'Credit Note';
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today().addDays(3);
        insert invRec;
        
        CustomInformation__c custRec  =  new CustomInformation__c();
        custRec.City__c ='Bangalore';
        custRec.Pin_Code__c ='480107';
         
        insert custRec;
        
    }

}