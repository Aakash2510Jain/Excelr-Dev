global without sharing class BatchToDeleteAssignmentGroupMember implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Assignment_Group_Member__c WHERE End_Date__c < TODAY';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Assignment_Group_Member__c> agmList) {
        List<Assignment_Group_Member__c> recordsToDelete = new List<Assignment_Group_Member__c>();
        for (Assignment_Group_Member__c agmRec : agmList) {
            recordsToDelete.add((Assignment_Group_Member__c)agmRec);
        }
        delete recordsToDelete;
    }
 
    global void finish(Database.BatchableContext BC) {
        // Optional finishing logic here
    }
}