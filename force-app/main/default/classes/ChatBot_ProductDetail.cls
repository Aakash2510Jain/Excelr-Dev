public class ChatBot_ProductDetail {
 @InvocableMethod(label='Get Product URLDetails')
    public static List<Product2> getProductlist(List<string> prodName){
        system.debug('custId--'+prodName);
        List<Product2> prodList = [select name,id,DisplayUrl,Description from Product2 where name IN:prodName];
        
        Return prodList;
    }
}