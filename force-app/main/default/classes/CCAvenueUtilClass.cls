public with sharing class CCAvenueUtilClass {
    public static String encryptString(String Plain_Text, String encrypKey){
        try{
        Blob cryptoKey          = Blob.valueOf(encrypKey);       
        Blob hash               = Crypto.generateDigest(DN_ServiceConstants.HASH_FUNCTION_ALOGORITHM, cryptoKey);        
        Blob data               = Blob.valueOf(Plain_Text);  
        Blob encryptedData      = Crypto.encryptWithManagedIV(DN_ServiceConstants.ENCRYPTION_ALOGORITHM, hash , data);        
        return EncodingUtil.convertToHex(encryptedData);
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPICallout', 'getEmployeeDetails', e , null);
       return null;
    }
}
}