/* Author : Isha Raaz */

public without sharing class BatchToSendRazorPayPaymentLink implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private List<Id> listOfOppIds;
    public BatchToSendRazorPayPaymentLink(List<Id> listOfOppIds) {
        this.listOfOppIds = listOfOppIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Name,Amount,Email__c,Phone__c From Opportunity WHERE Id IN : listOfOppIds]);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> listOfAllOpportunity){

        system.debug('listOfAllOpportunity ===> '+listOfAllOpportunity);
        if(!listOfAllOpportunity.isEmpty()){
            RazorpayPaymentHandler.sendPaymentLink(listOfAllOpportunity[0].Id);
        }
    }

    public void finish(Database.BatchableContext bc){
        system.debug('The Batch Run Successfully');
    }
}