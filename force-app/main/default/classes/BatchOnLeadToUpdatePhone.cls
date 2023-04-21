global without sharing class BatchOnLeadToUpdatePhone implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string queueId =[SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Excelr Default Queue' limit 1].id;
        return Database.getQueryLocator([SELECT Id,Name,Phone,Alternate_Phone__c,Email,Email_To_be_Mapped__c,Phone_to_be_Mapped__c,Alternate_Email__c FROM Lead WHERE (Phone != null OR Alternate_Phone__c != null OR Email != null or Alternate_Email__c != null) and isconverted = false] );
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> LeadList) {
        List<Lead> LeadListToBeUpdated = New List<Lead>();
        if(!LeadList.isEmpty()){
            
            for(Lead LeadRecord : LeadList){
                if(LeadRecord.Phone != null){
                    LeadRecord.Phone ='+'+(LeadRecord.Phone).replaceAll('[^0-9]+', '');
                }
                if(LeadRecord.Alternate_Phone__c != null){
                    LeadRecord.Alternate_Phone__c = '+'+(LeadRecord.Alternate_Phone__c).replaceAll('[^0-9]+', '');
                }
                
                if(LeadRecord.Phone != null){
                    LeadRecord.Phone_to_be_Mapped__c ='+'+(LeadRecord.Phone).replaceAll('[^0-9]+', '');
                }else{
                    if(LeadRecord.Alternate_Phone__c != null)
                        LeadRecord.Phone_to_be_Mapped__c = '+'+(LeadRecord.Alternate_Phone__c).replaceAll('[^0-9]+', '');
                }
                if(LeadRecord.Email != null){
                    LeadRecord.Email_To_be_Mapped__c = LeadRecord.Email;
                }else{
                    if(LeadRecord.Alternate_Email__c != null )
                    LeadRecord.Email_To_be_Mapped__c = LeadRecord.Alternate_Email__c;
                }
            }
            update LeadList;
        }        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
}