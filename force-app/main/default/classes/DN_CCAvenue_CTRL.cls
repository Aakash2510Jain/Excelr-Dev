/*
@Purpose     : This class creates a encrypted request for ccAvenue Payment Gateway 
@CreatedDate : 02/12/2022
@Author      : Baski
*/
public without sharing class DN_CCAvenue_CTRL {

    public string ACCESS_CODE   {get; set;}
    public String encRequest    {get; set;}
    public string postURL		{get; set;}


    public static String createPaymentURL(String oppId){

        try{

            CCAvenue_Details__c ccDetails = CCAvenue_Details__c.getInstance();
            
            String ACCESS_CODE = ccDetails.Non_FCRA_Access_Code__c;
            String MERCHANT_ID = ccDetails.Non_FCRA_Merchant_ID__c;
            String WORKING_KEY = ccDetails.Non_FCRA_Working_Key__c;
            String TRANSACTION_URL = ccDetails.CCAvenue_Transaction_URL__c;

            String AVENUE_CANCEL_URL = DN_ServiceConstants.AVENUE_CANCEL_URL+'?order_id='+oppId;
            String AVENUE_SUCCESS_URL = DN_ServiceConstants.AVENUE_SUCCESS_URL+'?order_id='+oppId;
            

            Opportunity opp = getOpportunity(oppId);

            Long tstamp = System.now().getTime();

            String params = 'tid='+opp.Name+tstamp+'&merchant_id='+MERCHANT_ID+'&order_id='+oppId+'&amount='+opp.Amount+'&currency='+'INR'+'&redirect_url='   +AVENUE_SUCCESS_URL+'&cancel_url='+AVENUE_CANCEL_URL+'&language=EN&billing_name='+opp.Name+'&billing_address='+opp.Account.BillingStreet+'&billing_city='+opp.Account.BillingCity+'&billing_state='+opp.Account.BillingState+'&billing_zip='+opp.Account.BillingPostalCode+'&billing_country='+opp.Account.BillingCountry+'&billing_tel='+opp.Account.Phone+'&billing_email='+opp.Account.Email__c+'&delivery_name='+opp.Name+'&delivery_address='+opp.Account.ShippingStreet+'&delivery_city='+opp.Account.ShippingCity+'&delivery_state='+opp.Account.ShippingState+'&delivery_zip='+opp.Account.ShippingPostalCode+'&delivery_country='+opp.Account.ShippingCountry+'&delivery_tel='+opp.Account.Phone;
            System.debug('params ===> ' + params); //opp.Name

            String encRequest = CCAvenueUtilClass.encryptString(params, WORKING_KEY);
            System.debug('encRequest ===> ' + encRequest);


            String paymentURL = TRANSACTION_URL + '/transaction/transaction.do?command=initiateTransaction&encRequest=' + encRequest + '&access_code=' + ACCESS_CODE;
            System.debug('Payment URL - '+paymentURL);

            return paymentURL;
        }catch(Exception e){
            Exceptions__c Exc = new Exceptions__c();
            Exc.Class_Name__c = 'DN_CCAvenue_CTRL';
			Exc.Error_Message__c = e.getMessage();     
            Exc.Error_Line_No__c = e.getLineNumber();
            Exc.Error_Stack_Trace__c = e.getStackTraceString();
            Exc.Error_Type__c = e.getTypeName();
            Exc.Method_Name__c = 'createPaymentURL';
            insert Exc;
            return null;
        }
    }

    public static String createPaymentURLFromInvoice(Invoice__c iv,Map<String,String> reqMap){
        try{
        System.debug('iv FROM Method ===> '+iv);
        Receipt__c rep = [SELECT id,Name,Amount__c FROM Receipt__c Where Invoice__c =: iv.id LIMIT 1];
        System.debug('rep Record Details ==> '+rep);


        CCAvenue_Details__c ccDetails = CCAvenue_Details__c.getInstance();
            
        String ACCESS_CODE = ccDetails.Non_FCRA_Access_Code__c;
        String MERCHANT_ID = ccDetails.Non_FCRA_Merchant_ID__c;
        String WORKING_KEY = ccDetails.Non_FCRA_Working_Key__c;
        String TRANSACTION_URL = ccDetails.CCAvenue_Transaction_URL__c;

           String AVENUE_CANCEL_URL = DN_ServiceConstants.AVENUE_CANCEL_URL+'?order_id='+iv.Opportunity__c+'&order_status=Fail';
            String AVENUE_SUCCESS_URL = DN_ServiceConstants.AVENUE_SUCCESS_URL+'?order_id='+iv.Opportunity__c+'&order_status=Success';
            

        Long tstamp = System.now().getTime();

        System.debug('rep.Amount__c ===> '+rep.Amount__c);
        String params = 'tid='+reqMap.get('name')+tstamp+'&merchant_id='+MERCHANT_ID+'&order_id='+iv.Id+'&amount='+rep.Amount__c+'&currency='+'INR'+'&redirect_url='   +AVENUE_SUCCESS_URL+'&cancel_url='+AVENUE_CANCEL_URL+'&language=EN&billing_name='+reqMap.get('name')+'&billing_address='+reqMap.get('billing_address')+'&billing_city='+reqMap.get('billing_city')+'&billing_state='+reqMap.get('billing_street')+'&billing_zip='+reqMap.get('billing_postal_code')+'&billing_country='+reqMap.get('billing_country')+'&billing_tel='+reqMap.get('phone')+'&billing_email='+reqMap.get('email')+'&delivery_name='+reqMap.get('name')+'&delivery_address='+reqMap.get('shipping_address')+'&delivery_city='+reqMap.get('shipping_city')+'&delivery_state='+reqMap.get('shipping_state')+'&delivery_zip='+reqMap.get('shipping_postal_code')+'&delivery_country='+reqMap.get('shipping_country')+'&delivery_tel='+reqMap.get('phone');
        System.debug('params ===> ' + params);

        String encRequest = CCAvenueUtilClass.encryptString(params, WORKING_KEY);
        System.debug('encRequest ===> ' + encRequest);

        String paymentURL = TRANSACTION_URL + '/transaction/transaction.do?command=initiateTransaction&encRequest=' + encRequest + '&access_code=' + ACCESS_CODE;
        System.debug('Payment URL - '+paymentURL);

        return paymentURL;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('DN_CCAvenue_CTRL', 'createPaymentURLFromInvoice', e , null);
       return null;
    }
}

    public static Opportunity getOpportunity(String oppId){
        return [Select Id,Name,Amount,Account.Phone,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,Account.ShippingCountry,Account.ShippingPostalCode,Account.Email__c From Opportunity Where Id=:oppId];
    }

    public DN_CCAvenue_CTRL(ApexPages.StandardController stdController){
        try{
            String Plain_Text;
            PageReference ReturnPage;
    
            string redirecturl='https://dev-firstcarwashcustomer.cs58.force.com/customer/CancelCCAvenue';
            string cancelURL='https://dev-firstcarwashcustomer.cs58.force.com/customer/CancelCCAvenue';
            //CCAvenueUtilClass.getencRequest
    
            CCAvenue_Details__c ccDetails   = CCAvenue_Details__c.getInstance();
            Opportunity op = (Opportunity)stdController.getRecord(); 
            String oppId = op.Id;
            String merchantId =  ccDetails.Non_FCRA_Merchant_ID__c;
            String workingKey = ccDetails.Non_FCRA_Working_Key__c;
    
            System.debug('OppId---'+oppId);
    
            Opportunity opp = [Select Id,Name,Amount,Account.Phone,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,Account.ShippingCountry,Account.ShippingPostalCode,Account.Email__c From Opportunity Where Id=:oppId];
            
            Long tstamp = System.now().getTime();
            
            Plain_Text  = 'tid='+opp.Name+tstamp+'&merchant_id='+merchantId+'&order_id='+opp.Name+'&amount='+opp.Amount+'&currency='+'INR'+'&redirect_url='+redirecturl+'&cancel_url='+cancelURL+'&language=EN&billing_name='+opp.Name+'&billing_address='+opp.Account.BillingStreet+'&billing_city='+opp.Account.BillingCity+'&billing_state='+opp.Account.BillingState+'&billing_zip='+opp.Account.BillingPostalCode+'&billing_country='+opp.Account.BillingCountry+'&billing_tel='+opp.Account.Phone+'&billing_email='+opp.Account.Email__c+'&delivery_name='+opp.Name+'&delivery_address='+opp.Account.ShippingStreet+'&delivery_city='+opp.Account.ShippingCity+'&delivery_state='+opp.Account.ShippingState+'&delivery_zip='+opp.Account.ShippingPostalCode+'&delivery_country='+opp.Account.ShippingCountry+'&delivery_tel='+opp.Account.Phone;
    
            encRequest = CCAvenueUtilClass.encryptString(Plain_Text, workingKey);
            ACCESS_CODE = ccDetails.Non_FCRA_Access_Code__c;
            
            postURL = ccDetails.CCAvenue_Transaction_URL__c + '/transaction/transaction.do?command=initiateTransaction';//&encRequest=' + encRequest + '&access_code=' + ACCESS_CODE;

            System.debug('URL-----'+postURL);
        }catch(Exception ex){
            Exceptions__c Exc = new Exceptions__c();
            Exc.Class_Name__c = 'DN_CCAvenue_CTRL';
			Exc.Error_Message__c = ex.getMessage();     
            Exc.Error_Line_No__c = ex.getLineNumber();
            Exc.Error_Stack_Trace__c = ex.getStackTraceString();
            Exc.Error_Type__c = ex.getTypeName();
            Exc.Method_Name__c = 'DN_CCAvenue_CTRL';
            insert Exc;
            System.debug('Exception----'+ex);
        }
    }
}