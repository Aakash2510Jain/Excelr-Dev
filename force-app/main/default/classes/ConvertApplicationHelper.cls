public without sharing class ConvertApplicationHelper {
    @AuraEnabled
    public static void convertApplicationToOpportunity(string applicationId){
        Application__c applicationRecord = [Select id,Opportunity__r.AccountId,Course__c,LID__c,Opportunity__r.Alternate_Email__c, Opportunity__r.Alternate_Phone__c, Opportunity__r.CID__c, Opportunity__r.City__c, Opportunity__r.Country__c, Opportunity__r.Course__c, Opportunity__r.Customers__c, Opportunity__r.Email__c, Opportunity__r.GCLID__c, Opportunity__r.GST_State__c, Opportunity__r.OwnerId, Opportunity__r.LID__c, Opportunity__r.Name, Opportunity__r.Phone__c, Opportunity__r.StageName, Opportunity__r.CloseDate From Application__c where id =: applicationId];
        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.AccountId = applicationRecord.Opportunity__r.AccountId;
        opportunityToInsert.Alternate_Phone__c = applicationRecord.Opportunity__r.Alternate_Phone__c;
        opportunityToInsert.CID__c = applicationRecord.Opportunity__r.CID__c;
        opportunityToInsert.City__c = applicationRecord.Opportunity__r.City__c;
        opportunityToInsert.Country__c = applicationRecord.Opportunity__r.Country__c;
        opportunityToInsert.Course__c = applicationRecord.Course__c;
        opportunityToInsert.Customers__c = applicationRecord.Opportunity__r.Customers__c;
        opportunityToInsert.Email__c = applicationRecord.Opportunity__r.Email__c;
        opportunityToInsert.GST_State__c = applicationRecord.Opportunity__r.GST_State__c;
        opportunityToInsert.OwnerId = applicationRecord.Opportunity__r.OwnerId;
        opportunityToInsert.LID__c = applicationRecord.LID__c;
        opportunityToInsert.Name = applicationRecord.Opportunity__r.Name+' - '+applicationRecord.Course__c;
        opportunityToInsert.Phone__c = applicationRecord.Opportunity__r.Phone__c;
        opportunityToInsert.StageName = 'Prospect';
        opportunityToInsert.CloseDate = system.today().addDays(10);
        insert opportunityToInsert;
        applicationRecord.Opportunity__c = opportunityToInsert.Id;
        Update applicationRecord;
        
    }
    
}