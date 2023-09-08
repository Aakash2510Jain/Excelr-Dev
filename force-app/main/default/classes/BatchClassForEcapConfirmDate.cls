global without sharing class  BatchClassForEcapConfirmDate implements database.batchable<Sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //  string queueId =[SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Excelr Default Queue' limit 1].id;
        return Database.getQueryLocator([SELECT Id, Name, ECAP_Confirm_Date__c FROM Account WHERE ECAP_Confirm_Date__c != null AND ECAP_Confirm_Date__c = TODAY] );
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accList) {
        
        System.debug('accList------>'+accList);
        group groupRec = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where  DeveloperName ='ISM_Team' limit 1];
        Stream__c streamRec = [SELECT ID,Name from Stream__c LIMIT 1];
        System.debug('groupRec----->'+groupRec);
        List<Program__c> progList = new List<Program__c>();
        List<Account> updateAccList = new List<Account>();
        
        for(Account accRec: accList){
            Program__c programRec = new Program__c();
            programRec.Account__c = accRec.Id;
            programRec.ownerId = groupRec.Id;
            programRec.Stream__c = streamRec.Id;
            progList.add(programRec);
            
            accRec.ECAP_Confirm_Date__c = accRec.ECAP_Confirm_Date__c.addYears(1);
            updateAccList.add(accRec);
        }
        insert progList;
        update updateAccList;
        System.debug('progList---->'+progList);
        System.debug('updateAccList--->'+updateAccList);
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
    
}