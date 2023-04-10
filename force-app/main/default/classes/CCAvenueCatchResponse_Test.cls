@isTest
public  class CCAvenueCatchResponse_Test {
    @IsTest static void test_CCAvenueCatchResponse(){
        try{
       CCAvenueCatchResponse.updatePaymentStatus('006N000000K268xIAB', 'Success') ;
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CCAvenueCatchResponse_Test', 'test_CCAvenueCatchResponse', e , null);
       
    }
    
}
}