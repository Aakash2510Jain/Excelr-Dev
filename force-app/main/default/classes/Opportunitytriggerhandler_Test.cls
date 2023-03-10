@isTest
public class Opportunitytriggerhandler_Test {
    Public static  testMethod void testOnOpportunity(){
        Profile p1 = [Select Id from Profile where Name = 'Senior Inside Sales Manager' limit 1];   
        User user2 = new User();
        user2.Username = 'us2@test.com';
        user2.Email = 'us2@test.com';
        user2.LastName = 'LastName';
        user2.FirstName = 'FirstName2';
        user2.Alias ='u2';
        user2.CommunityNickname ='use2';
        user2.ProfileId =p1.id;
         user2.EmailEncodingKey='UTF-8';
        user2.LanguageLocaleKey='en_US';
        user2.LocaleSidKey='en_US';
        user2.TimeZoneSidKey='America/Los_Angeles';
        user2.Country = 'US';
        user2.Title = 'Field Service Manager';
        user2.Working_Days__c ='Monday';
        user2.Working_End_Time__c =time.newInstance(5, 30, 3, 3); 
        user2.Working_Start_Time__c = time.newInstance(12, 30, 3, 3); 
        user2.Start_Date__c = system.today(); 
        user2.End_Date__c = system.today();   
        insert user2;
        
        
        
        Account acc = new Account();
        acc.Name = 'Aakash';
        acc.OwnerId = user2.id;
        insert acc;
        
        map<id,Opportunity> mapNew = new map<id,Opportunity>();
         Opportunity oppRec = new Opportunity();
        oppRec.Name = 'OppTest';
        oppRec.AccountId = acc.id;
        oppRec.StageName = 'Prospect';
        oppRec.CloseDate = system.today();
        insert oppRec;
        mapNew.put(oppRec.id,oppRec);
        
        Map<id,Opportunity> mapOld = new  Map<id,Opportunity>();
        Opportunity oppRec1 = new Opportunity();
        oppRec1.Id = oppRec.id;
        oppRec1.AccountId = acc.id;
        oppRec1.StageName = 'Prospect';
        oppRec1.CloseDate = system.today();
        update oppRec1;
        mapOld.put(oppRec1.id,oppRec1);
        
        
        
        
        Invoice__c invRec = new Invoice__c();
        invRec.Opportunity__c =  oppRec1.Id ;
        invRec.OwnerId =  acc.OwnerId ;
        invRec.Status__c = 'Initiated';
        invRec.Amount__c = 2000;
        invRec.Type__c = 'Credit Note';
        invRec.Initiated_Date__c = System.Today();
        invRec.Invoice_Due_Date__c = System.Today().addDays(3);
        insert invRec;
        
        Task tsk = new Task();
        tsk.Subject = 'Test Task';
        tsk.Status = 'Open';
        tsk.Priority = 'Normal';
        tsk.WhatId = acc.ID;
        tsk.OwnerId = acc.OwnerId;
        insert tsk;
        
        
    }
}