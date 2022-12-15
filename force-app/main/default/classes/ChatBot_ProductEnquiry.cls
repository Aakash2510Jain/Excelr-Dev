Global class ChatBot_ProductEnquiry {
 @InvocableMethod(label='Product Enquiry')
    Global static List<List<string>> getProductlist(){
        List<Product2> prodList = [select name,id,DisplayUrl from Product2];
        list<string> productName = New List<string>();
        for(Product2 prod:prodList){
            productName.add(prod.Name);
        }
        return New List<List<string>> {productName};
    }
}