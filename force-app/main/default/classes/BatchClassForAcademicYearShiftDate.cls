global without sharing class  BatchClassForAcademicYearShiftDate implements database.batchable<Sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //  string queueId =[SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Excelr Default Queue' limit 1].id;
        return Database.getQueryLocator([SELECT Id,Name,Academic_Year_Shift_Date__c FROM Account WHERE  Academic_Year_Shift_Date__c != null AND Academic_Year_Shift_Date__c = TODAY]);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accList) {
        Set<ID> accIds = new Set<ID>();
        
        if(!accList.isEmpty()){
            System.debug('accList---->'+accList); 
            for(Account accRec:accList){
                accIds.add(accRec.Id);
            }
        }
        
        List<Student_Academic_Year__c> updateStdAcdList = new List<Student_Academic_Year__c>();
        List<Student_Academic_Year__c> stdAcadYearList = [SELECT ID, Current_Year__c, Account__c FROM Student_Academic_Year__c WHERE Account__c IN: accIds];
        if(!stdAcadYearList.isEmpty()){
            for(Student_Academic_Year__c stdAcRec : stdAcadYearList){
                if(stdAcRec.Current_Year__c != 4 && stdAcRec.Current_Year__c != 0 && stdAcRec.Current_Year__c != null ){
                    stdAcRec.Current_Year__c += 1;
                    updateStdAcdList.add(stdAcRec);
                }
            }
            update updateStdAcdList;
        }  
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch ran successfully');
    }
    
}