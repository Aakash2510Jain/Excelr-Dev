public without sharing class TestUtility {
    public static User insertUser(){
        User userRec = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'aakash.jain@mailinator.com',
            Username = 'aakash.jain@mailinator.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Max_Lead_Per_Month__c = 300,
            Start_Date__c = system.today(),
            End_Date__c = system.today()
        );
        return userRec;  
    }
    public static Assignment_Group__c insertAG(string AGName){
        Assignment_Group__c agRec = new Assignment_Group__c();
        agRec.name= AGName;
        return agRec;
    }
    public static Assignment_Group_Member__c insertAGM(integer maxLead, boolean active, boolean outOfOffice){
        Assignment_Group_Member__c agmRec = new Assignment_Group_Member__c();
        agmRec.Max_Lead_Per_Day__c = maxLead;
        agmRec.Active__c = active;
        agmRec.Out_Of_Office__c = outOfOffice;
        return agmRec;
    }
}