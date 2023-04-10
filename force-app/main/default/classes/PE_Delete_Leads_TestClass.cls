@isTest
public class PE_Delete_Leads_TestClass {
    Public static  testMethod void PEDeleteLeadTest(){
        Test.startTest();
        Lead ld = new Lead();
        ld.LastName = 'Aakash';
        ld.Company = 'UtilitarianLab';
        insert ld;
        Delete_Lead__e DeleteLeadRecord = new Delete_Lead__e();
        DeleteLeadRecord.LeadId__c = ld.Id;
        Database.SaveResult results = EventBus.publish(DeleteLeadRecord);
        test.stopTest();
    }
}