public without sharing class ConvertLeadHelper{
    @auraEnabled
    public static void convertLead(string recordId){
        if (!String.isBlank(recordId)){
            system.debug('recordId-->' + recordId);
            String leadId = '';
            List<Application__c> applicationsToBeUpdated = new List<Application__c>();
            List<Application__c> applicationsLinkedToLead = new List<Application__c>();


            leadId = [Select Lead__c
                      From Application__c
                      where Id = :recordId].Lead__c;

            for (Lead leadObj : [Select Id, Name, Email, isConverted
                                 from Lead
                                 Where Id = :leadId and isConverted = false]){

                Database.LeadConvert lc = new Database.LeadConvert();

                lc.setLeadId(leadObj.Id);
                lc.setDoNotCreateOpportunity(false);

                LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted
                                            FROM LeadStatus
                                            WHERE IsConverted = true
                                            limit 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);

                try{
                    //convert the lead. Try Catch is used to display the error message
                    Database.LeadConvertResult lcResults = Database.convertLead(lc);
                    system.debug('lcResults-->' + lcResults);
                    if (lcResults.isSuccess()){
                        applicationsLinkedToLead = [Select Id, Account__c
                                                    From Application__c
                                                    where Lead__c = :leadId];
                        for (Application__c appRec : applicationsLinkedToLead){
                            Application__c appRecToUpdate = new Application__c();
                            appRecToUpdate.Id = appRec.Id;
                            appRecToUpdate.Account__c = lcResults.accountid;
                            applicationsToBeUpdated.add(appRecToUpdate);
                        }
                        if (!applicationsToBeUpdated.isEmpty()){
                            update applicationsToBeUpdated;
                        }

                    }
                } Catch (Exception ex){
                    system.debug('Error -->' + ex.getMessage());
                    system.debug('Error -->' + ex.getLineNumber());
                }
            }
        }
    }

}