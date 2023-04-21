global with sharing class LeadEmailPhoneAppendBatchClass  implements DataBase.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
    string query = 'SELECT Alternate_Email__c,Alternate_Phone__c,Email,Email_To_be_Mapped__c,Phone,Phone_to_be_Mapped__c FROM Lead WHERE Alternate_Email__c != null OR Alternate_Phone__c != null OR Email != null OR Phone != null' ;
    return Database.getQueryLocator(query);
       
    }
    global void execute(Database.BatchableContext BC, List<Lead> leadlist){
       // List<lead> listTobeUpdated = new List<Lead>();
        for(Lead leadRec : leadlist){
          //  Lead leadUpdate = new Lead();
            if(leadRec.Phone != null){
                leadRec.Phone = '+'+ leadRec.Phone ;
            }

            if(leadRec.Alternate_Phone__c != null){
                leadRec.Alternate_Phone__c = '+'+ leadRec.Alternate_Phone__c ;
            }

            if(leadRec.Phone != null){
                leadRec.Phone_to_be_Mapped__c = leadRec.Phone; 
            }else if(leadRec.Alternate_Phone__c != null){
                leadRec.Phone_to_be_Mapped__c = leadRec.Alternate_Phone__c;
            }

            if(leadRec.Email != null){
                leadRec.Email_To_be_Mapped__c = leadRec.Email;
            }else if( leadRec.Alternate_Email__c != null ){
                leadRec.Email_To_be_Mapped__c = leadRec.Alternate_Email__c;
            }
            //listTobeUpdated.add(leadRec);
            
        }
        update leadlist;
         
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}