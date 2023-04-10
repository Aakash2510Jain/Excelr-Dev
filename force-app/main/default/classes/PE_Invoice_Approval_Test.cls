@isTest
public class PE_Invoice_Approval_Test {
    Public static  testMethod void PEInvoiceApprovalTest(){    
        Test.startTest();
        Invoice_Approval__e invApproval = new Invoice_Approval__e();
        invApproval.Invoice_Id__c = null;
        Database.SaveResult results = EventBus.publish(invApproval);
        test.stopTest();
    }
}