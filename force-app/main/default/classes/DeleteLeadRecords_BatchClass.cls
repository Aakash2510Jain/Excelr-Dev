global class DeleteLeadRecords_BatchClass implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
    string  query  = 'SELECT Id,LastName FROM Lead WHERE LastName LIKE \'%Testing%\' ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Lead> leadlist){
        List<Lead> deleteLeadRec = (List<Lead>) leadList;
            delete deleteLeadRec;
        system.debug('deleteRecord---'+deleteLeadRec);
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}