public class PE_Delete_Lead_elper {
    
    public static void deleteLeadRecords(List<Delete_Lead__e> DeleteLeadList){

        set<Id> LeadIds = new Set<Id>();
        if (!DeleteLeadList.isEmpty()) {
            for (Delete_Lead__e DelLead : DeleteLeadList) {
                if (DelLead.LeadId__c != null) {
                    LeadIds.add(DelLead.LeadId__c);
                }
            }

            if (!LeadIds.isEmpty()) {
                delete [select Id from Lead where ID IN:LeadIds];
            }
            
        }



    }
}