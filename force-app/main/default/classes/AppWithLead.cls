public with sharing class AppWithLead
 {
    public AppWithLead() {

    }
    @AuraEnabled(Cacheable = true)
    public static List<Application__c> fetchApp(String recordId)
    {
        List<Application__c> app = [select Id,Name,Course__c, Applied_Date_Time__c,LID__c,Lead__c from Application__c where Lead__c =:recordId ];

        return app;
    }
}