@isTest
public without sharing class PE_Receipt_Approval_Test {
    Public static  testMethod void PEInvoiceApprovalTest(){    
        Test.startTest();
        Receipt_Approval__e retApproval = new Receipt_Approval__e();
        retApproval.Opportunity_Id__c = null;
        Database.SaveResult results = EventBus.publish(retApproval);
        test.stopTest();
    }
}