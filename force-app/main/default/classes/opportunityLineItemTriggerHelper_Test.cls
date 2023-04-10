@isTest
public class opportunityLineItemTriggerHelper_Test {
    public static TestMethod void  getOliRec(){
        Map<Id, OpportunityLineItem> mapOli = new Map<Id, OpportunityLineItem>();
        Product2 pro = new Product2();
        pro.name = 'test';
        insert pro;
         
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
        mapOli.put(oli.id,oli);
        
        
    }
}