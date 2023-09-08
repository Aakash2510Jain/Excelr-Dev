global without sharing class BatchClassforProgramStartDateTime implements database.batchable<Sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([SELECT Id, Name, Account__c, Aptitude_Test_Date_Time__c, Stage__c FROM Program__c WHERE Aptitude_Test_Date_Time__c != null AND Aptitude_Test_Date_Time__c = TODAY] );
    }
    
    global void execute(Database.BatchableContext bc, List<Program__c> progList) {
        System.debug('progList----->'+progList);
        set<ID> accountIds = new set<Id>();
        if(!progList.isEmpty()){
            List<Program__c> updateProgList = new List<Program__c>();
            for(Program__c progRec: progList){                 
                progRec.Stage__c = 'ECAP Initiated';
                updateProgList.add(progRec);
                accountIds.add(progRec.Account__c);
            }
            update updateProgList;
            System.debug('updateProgList---->'+updateProgList);
            List<String> conEmaiList = new List<String>();
            List<Contact> contactList = [SELECT Id, Name, Email FROM Contact where AccountId IN:accountIds and Designation__c ='Placement Officer']; 
            sendEmail(accountIds);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
    
    public static void sendEmail(set<ID> accountIds){
        
        List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
        System.debug('conEmaiList---->'+accountIds);
        List<String> conEmaiList = new List<String>();
        List<Contact> contactList = [SELECT ID, Name, LastName, FirstName, Email FROM Contact where AccountId IN:accountIds and Designation__c ='Placement Officer']; 
        for(Contact conRec:contactList){
            if(conRec.Email !=null){
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(new string[] {conRec.Email} );  //conEmaiList
                mymail.setSenderDisplayName('Excelr');
                mymail.setSubject('Placement Drive');
                mymail.setSaveAsActivity(false);
                mymail.setPlainTextBody('Hello ,'+conRec.LastName +'' +'\n'+'\n' + 'Aptitude Test at your College for your graduating students on behalf of ExcelR as part of ' +  + 'has been conducted Today.'+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                semList.add(mymail);
            }
        }     
        Messaging.sendEmail(semList);
    }
        
}