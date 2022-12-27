@isTest
public class bankDetaklsLwcContrroler_Test {
    @IsTest static void test_bankDetaklsLwcContrroler(){
        bankDetaklsLwcContrroler.createBankDetails('testingAccount', 'testBankName','testIFSCCOde', 'test@gmail.com', '9876543212');
         Account accRec = new Account(Name= 'Akash',Email__c= 'Jain@gmail.com');
        insert accRec;
        bankDetaklsLwcContrroler.createBankDetails('testingAccount1', 'testBankName', 'testIFSCCOde', 'Jain@gmail.com', '9876543212'); 
      
    }
}