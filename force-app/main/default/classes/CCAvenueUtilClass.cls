public without sharing class CCAvenueUtilClass {
    public static String encryptString(String Plain_Text, String encrypKey){
        try{
            Blob cryptoKey          = Blob.valueOf(encrypKey);       
            Blob hash               = Crypto.generateDigest(DN_ServiceConstants.HASH_FUNCTION_ALOGORITHM, cryptoKey);        
            Blob data               = Blob.valueOf(Plain_Text);  
            Blob encryptedData      = Crypto.encryptWithManagedIV(DN_ServiceConstants.ENCRYPTION_ALOGORITHM, hash , data);        
            return EncodingUtil.convertToHex(encryptedData);
        }catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CCAvenueUtilClass', 'encryptString', e , null);
            return null;
        }
    }
    
    public static Map<string,string> decryptString(string encryptedResponse, string encrypKey){
        try{
            Blob encryptedresponseData 						= EncodingUtil.convertFromHex(encryptedResponse);
            System.debug('encryptedresponseData ====> ' + encryptedresponseData);
            Blob cryptoKey          = Blob.valueOf(encrypKey); 
            System.debug('cryptoKey ====> ' + cryptoKey);      
            Blob hash               = Crypto.generateDigest(DN_ServiceConstants.HASH_FUNCTION_ALOGORITHM, cryptoKey);    
            System.debug('hash ====> ' + hash);
            //Decrypt the data - the first 16 bytes contain the initialization vector
            Blob decryptedData = Crypto.decryptWithManagedIV(DN_ServiceConstants.ENCRYPTION_ALOGORITHM, hash, encryptedresponseData);
            //Get decrypted data 
            String decryptedDataString = decryptedData.toString();
            System.debug('decryptedDataString =====> ' + decryptedDataString);
            Map<string,string> responseMap = processCCAvenueResponse(decryptedDataString);
            return responseMap;
            
        }
        catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CCAvenueUtilClass', 'getEmployeeDetails', e , null);
            return null;
        }
    }

    public static Map<string,string>  processCCAvenueResponse(string resposne){

        string message = '';
        String responsereplaced = resposne.replace('?', '&');
        System.debug('responsereplaced ====> ' + responsereplaced);
        String[] resDetails = responsereplaced.split('&');
        Map<string,string> responseMap		= new Map<string,string>();

        System.debug('resDetails ====> ' + resDetails);

        for (String str : resDetails) {
            System.debug('str =====> ' + str);
            String[] SingleStr = str.split('=');
            System.debug('SingleStr.size() ====> ' + SingleStr.size());
            System.debug('SingleStr ====> ' + SingleStr);
            if (SingleStr.size() > 1) {
                if (SingleStr[0] != null && SingleStr[0] != '' && SingleStr[1] != null && SingleStr[1] != '') {
                    System.debug('SingleStr[0] =====> ' + SingleStr[0]);
                    System.debug('SingleStr[1] =====> ' + SingleStr[1]);
                    responseMap.put(SingleStr[0], SingleStr[1]);                
                }
                
            }
            
            
        }   
        System.debug('responseMap ====> ' + responseMap );
        System.debug('responseMap.orderid ====> ' + responseMap.get('order_id') );
        
        return responseMap;

    }
}