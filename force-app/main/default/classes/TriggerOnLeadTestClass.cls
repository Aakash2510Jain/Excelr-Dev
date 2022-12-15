@isTest
public  class TriggerOnLeadTestClass {
    public static testMethod void testLeadRecClass() {
        //list<Lead> leadlist = new list<Lead>();
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'Util';
        ld.Course__c = '';
        insert ld;
        
        Map<id,Lead> maplead = new Map<id,Lead>();
        maplead.put(ld.id, ld);
        
        Lead ld1 = new Lead();
        ld1.LastName = 'Test2';
        ld1.Company = 'Util2';
        ld.Course__c = 'Data Science Course Training';
        ld1.id= ld.id;
        insert ld1;

      }
}