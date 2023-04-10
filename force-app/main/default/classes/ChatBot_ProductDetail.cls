public without sharing class ChatBot_ProductDetail {
 @InvocableMethod(label='Get Product URLDetails')
    public static List<Product2> getProductlist(List<string> prodName){
        try{
            system.debug('custId--'+prodName);
            List<Product2> prodList = [select name,id,DisplayUrl,Description from Product2 where name IN:prodName];
            
            Return prodList;
            } catch (Exception e){
                system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatBot_ProductDetail', 'getProductlist', e , null);
            return null;
            }
}
}