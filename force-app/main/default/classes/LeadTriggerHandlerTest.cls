@isTest
public  class LeadTriggerHandlerTest {
    public static testMethod void testLeadRecClass() {
        List<Lead> leadList =new List<Lead>();
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'Util';
        ld.Country__c = 'Core Python Training';
        ld.Enter_UTM_Link__c ='http//www.google.com';
        leadList.add(ld);
        insert leadList;
        
        test.startTest();
        LeadTriggerHandler var = new LeadTriggerHandler();
        var.beforeInsert(leadList);
        var.afterInsert(leadList);
        test.stopTest();
    }
    
    public static testMethod void testLeadRecClass1() {
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'Util';
        ld.Enter_UTM_Link__c ='http//www.google.com';
        
        insert ld;
        Map<Id, Lead> newLeadMap = new  Map<Id, Lead>();
        newLeadMap.put(ld.id,ld);
        
        Lead ld1 = new Lead();
        ld1.LastName = 'Test';
        ld1.Company = 'Util';
        ld1.Enter_UTM_Link__c ='http//www.google.com';
        insert ld1;
        
        Map<Id, Lead> newLeadMap1 = new  Map<Id, Lead>();
        newLeadMap1.put(ld1.id,ld1);
        
        test.startTest();
        LeadTriggerHandler var = new LeadTriggerHandler();
        
        var.beforeUpdate(newLeadMap,newLeadMap1);
        var.afterUpdate(newLeadMap,newLeadMap1);
        test.stopTest();
    }   
    /*public static testMethod void testLeadRecClass() {
        List<Lead> leadList =new List<Lead>();
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'Util';
        ld.Enter_UTM_Link__c ='http//www.google.com';
        ld.Course__c ='Core Python Training';
        leadList.add(ld);
        insert leadList;
        
        /* test.startTest();
LeadTriggerHandler var = new LeadTriggerHandler();
var.beforeInsert(leadList);
var.afterInsert(leadList);
test.stopTest();*/
    }
    /*
    public static testMethod void testLeadRecClass1() {
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'Util';
        ld.Enter_UTM_Link__c ='http//www.google.com';
        ld.Course__c ='Core Python Training';
        insert ld;
        Map<Id, Lead> newLeadMap = new  Map<Id, Lead>();
        newLeadMap.put(ld.id,ld);
        
        Lead ld1 = new Lead();
        ld1.LastName = 'Test';
        ld1.Company = 'Util';
        ld1.Course__c ='Core Python Training';
        ld1.Enter_UTM_Link__c ='http//www.google.com';
        insert ld1;
        
        Map<Id, Lead> newLeadMap1 = new  Map<Id, Lead>();
        newLeadMap1.put(ld1.id,ld1);
        */
        /* test.startTest();
LeadTriggerHandler var = new LeadTriggerHandler();

var.beforeUpdate(newLeadMap,newLeadMap1);
var.afterUpdate(newLeadMap,newLeadMap1);
test.stopTest();*/