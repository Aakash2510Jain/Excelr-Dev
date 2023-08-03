public class DeleteLeadRecords_BatchClass_Ctrl {
   // @AuraEnabled
    public DeleteLeadRecords_BatchClass_Ctrl(ApexPages.StandardSetController leadcontroller){
        
    }
     
    public static void deleteLeadRecords(){
        
        DeleteLeadRecords_BatchClass leadbatch = new DeleteLeadRecords_BatchClass();
        
        Database.executeBatch( leadbatch);
        system.debug('leadbatch---'+leadbatch);
    }

}