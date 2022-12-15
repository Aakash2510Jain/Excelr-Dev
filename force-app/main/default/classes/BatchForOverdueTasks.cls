global class BatchForOverdueTasks implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date todayDate = system.today();
        todayDate = todayDate.addDays(-1);
        
        String query = 'SELECT Id,Name,whoId FROM Task where ActivityDate	=: todayDate limit 10000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> taskList) {
        List<Case> caseList = new List<Case>();
        
        if(!taskList.isEmpty()){
            for(Task taskRec : taskList){
                Case caseRec = new Case();
                caseRec.Subject = 'Escalation due to overdue task';
                caseRec.Lead__C = taskRec.WhoId;
                caseList.add(caseRec); 
            }
            if(!caseList.isEmpty()){
                insert caseList;
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}