public with sharing class ProductUpdateOnOppApexController {
    
    @AuraEnabled(Cacheable=True)
    Public static List<City__c> fetchCities(){
        List<City__c> citylist=[Select Name From City__c];
        system.debug('citylist='+citylist);
        return citylist;
    }
    
    @AuraEnabled
    Public static List<Product2> ProdList(string mode,string typevalue ,string city){
        List<Product2> ProdList=[Select Id,Name, Mode__c, Type__c,City__c,Description,ProductCode,(Select UnitPrice From PricebookEntries where IsActive = true) From Product2 Where IsActive = true AND Mode__c=:mode AND Type__c=:typevalue AND City__c=:city];
        
        return ProdList;
    }
    
    @AuraEnabled
    Public static string InsertOppLineItem(List<Product2> Prodlist){
        
        system.debug('Prodlist='+Prodlist);
        List<OpportunityLineItem> oppLitemList=new List<OpportunityLineItem>();
        
        for(Product2 prodRec:Prodlist){
            
            PricebookEntry PBentryRec=[Select Id,UnitPrice From PricebookEntry where Pricebook2.Name='Standard Price Book' AND Product2Id=:prodRec.Id];
            system.debug('PBentryRec=='+PBentryRec);
            OpportunityLineItem oppLitemRec=new OpportunityLineItem();
            oppLitemRec.Product2Id=prodRec.Id;
            oppLitemRec.Mode__c=prodRec.Mode__c;
            oppLitemRec.Type__c=prodRec.Type__c;
            //oppLitemRec.UnitPrice=prodRec.Amount__c;
            oppLitemRec.Discount=prodRec.Discount__c;
            oppLitemRec.OpportunityId='006N000000K1A06IAF';
            oppLitemRec.PricebookEntryId=PBentryRec.Id;
            oppLitemRec.TotalPrice=PBentryRec.UnitPrice-(PBentryRec.UnitPrice*(prodRec.Discount__c/100));
            system.debug('oppLitemRec.TotalPrice==='+oppLitemRec.TotalPrice);
            oppLitemRec.Quantity=1;
            oppLitemList.add(oppLitemRec);
        }
        if(!oppLitemList.IsEmpty()){
            insert oppLitemList;
        }
        return 'success';
    }

}