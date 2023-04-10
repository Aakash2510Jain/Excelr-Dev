public without sharing class DeleteDuplicateLeads {
    public static void deleteLeads(){

        Set<Id> LeadIds = new Set<Id>();
        List<Lead> LeadstobeDeleted = [select Id, ownerId from Lead where To_Be_Deleted__c = true limit 1000];
        List<Delete_Lead__e> DeleteLeadRecordList = new List<Delete_Lead__e>();

        if (!LeadstobeDeleted.isEmpty()) {
            for (Lead LeadRec : LeadstobeDeleted) {
                Delete_Lead__e DeleteLeadRecord = new Delete_Lead__e();
                DeleteLeadRecord.LeadId__c = Leadrec.Id;
                DeleteLeadRecordList.add(DeleteLeadRecord);
            }
        }
        
        if (!DeleteLeadRecordList.isEmpty()) {
            Database.SaveResult[] results = EventBus.publish(DeleteLeadRecordList);
            for (Integer i = 0, s = results.size(); i < s; i++){
                if (!results[i].isSuccess()){

                    // report an error here //

                    // You can tell if it was an approval lock by: //
                    for (Database.Error e : results[i].getErrors()){
                        System.debug('Error ====> ' + e);
                    }
                }
                else if(results[i].isSuccess()){
                    System.debug('Success Id ====> ' + results[i].getId());
                }
            }
        }            
        //delete [select Id from Lead where To_Be_Deleted__c = true limit 1000];
    }
        
 }