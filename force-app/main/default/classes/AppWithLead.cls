public without sharing  class AppWithLead
 {
    public AppWithLead() {

    }
    @AuraEnabled(Cacheable = true)
    public static List<Application__c> fetchApp(String recordId)
    {
        try{
        List<Application__c> app = [select Id,Name,Course__c, Applied_Date_Time__c,LID__c,Lead__c from Application__c where Lead__c =:recordId ];

        return app;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('AppWithLead', 'BfetchApp', e , null);
      return null;
    }
}
}