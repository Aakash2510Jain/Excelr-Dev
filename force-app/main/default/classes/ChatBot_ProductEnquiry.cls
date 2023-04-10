Global without sharing class ChatBot_ProductEnquiry {
 @InvocableMethod(label='Product Enquiry')
    Global static List<List<string>> getProductlist(){
        try{
            List<Product2> prodList = [select name,id,DisplayUrl from Product2];
            list<string> productName = New List<string>();
            for(Product2 prod:prodList){
                productName.add(prod.Name);
            }
            return New List<List<string>> {productName};
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
          HandleBusinessException.captureError('ChatBot_ProductEnquiry', 'getProductlist', e , null);
           return null;
        }
}
}