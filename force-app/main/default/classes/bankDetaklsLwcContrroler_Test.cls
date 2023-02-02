@isTest
public class bankDetaklsLwcContrroler_Test {
    @IsTest static void test_bankDetaklsLwcContrroler(){
        try{
        bankDetaklsLwcContrroler.createBankDetails('testingAccount', 'testBankName','testIFSCCOde', 'test@gmail.com', '9876543212');
         Account accRec = new Account(Name= 'Akash',Email__c= 'Jain@gmail.com');
        insert accRec;
        bankDetaklsLwcContrroler.createBankDetails('testingAccount1', 'testBankName', 'testIFSCCOde', 'Jain@gmail.com', '9876543212'); 
        }catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
          HandleBusinessException.captureError('bankDetaklsLwcContrroler_Test', 'test_bankDetaklsLwcContrroler', e , null);
          
        }
     }
}