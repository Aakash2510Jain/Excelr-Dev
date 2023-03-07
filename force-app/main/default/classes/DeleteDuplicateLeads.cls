public class DeleteDuplicateLeads {
    public static void deleteLeads(){
        delete [select Id from Lead where To_Be_Deleted__c = true limit 1000];
    }

}