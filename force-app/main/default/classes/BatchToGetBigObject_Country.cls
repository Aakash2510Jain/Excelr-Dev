public class BatchToGetBigObject_Country implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        return Database.getQueryLocator([select State__c from Country_and_State__b where country__c = 'India' ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Country_and_State__b> countryList) {
        system.debug('countryList::'+countryList.size());
    }
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}