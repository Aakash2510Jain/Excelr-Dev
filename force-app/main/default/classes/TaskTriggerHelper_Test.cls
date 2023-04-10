@isTest
public class TaskTriggerHelper_Test {
    Public static  testMethod void testOnTask(){
        
         /*Profile p1 = [Select Id from Profile where Name = 'Sales Manager' limit 1];   
        User user2 = new User();
        user2.Username = 'us2222@test.com';
        user2.Email = 'us222@test.com';
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
        insert user2;*/
        
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.OwnerId = UserInfo.getUserId();
        insert acc;
        
        Map<id,Task> mapNew = new Map<id,Task>();
        Task taskRec = new Task();
        taskRec.Subject = 'Call';
        taskRec.OwnerId = acc.OwnerId;
        taskRec.WhatId = acc.id;
        taskRec.Updated_Time__c = 0;
        taskRec.CallObject = 'jjkjf';
        insert taskRec;
        mapNew.put(taskRec.id,taskRec);
        
        Map<id,Task> mapold = new Map<id,Task>();
        Task taskRec1 = new Task();
        taskRec1.id = taskRec.id;
        taskRec.Subject = 'Send Letter';
        taskRec1.OwnerId = acc.OwnerId;
        taskRec1.WhatId = acc.id;
        taskRec1.Updated_Time__c = 0;
        taskRec.CallObject = 'jjkjfxvvxf';
        update taskRec1;
        mapold.put(taskRec1.id,taskRec1);
        
        /*test.startTest();
        TaskTriggerHelper var = TaskTriggerHelper ();
        var.beforeUpdate(mapNew, mapold);
        test.stopTest();*/
    }

}