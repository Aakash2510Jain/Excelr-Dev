//@RESTResource(urlMapping = '/ccavenueDynamicresponse/*')
global without sharing class CCAvenueDynamicEventResponse{
    public String headerdata{ get; set; }

    public string urlvalue{ get; set; }

    public string url{ get; set; }

    //@HttpPost
    global static String ResponseForCCavenueResponseHandler(){
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            String body = req.requestBody.toString();
            system.debug('body ===> ' + body);
            return body;
        } catch (Exception e){
            return null;
        }
    }

    public PageReference CCAvenueresponse(){

        try{
            CCAvenue_Details__c ccDetails = CCAvenue_Details__c.getInstance();

            String ACCESS_CODE = ccDetails.Non_FCRA_Access_Code__c;
            String MERCHANT_ID = ccDetails.Non_FCRA_Merchant_ID__c;
            String WORKING_KEY = ccDetails.Non_FCRA_Working_Key__c;
            String TRANSACTION_URL = ccDetails.CCAvenue_Transaction_URL__c;

            headerdata = ApexPages.currentPage().getHeaders().get('Host');
            system.debug('headerdata =====> ' + headerdata);

            urlvalue = Apexpages.currentPage().getUrl();
            system.debug('urlvalue =====> ' + urlvalue);

            url = 'https://' + headerdata + urlvalue;
            system.debug('url =====> ' + url);


            String status = ApexPages.currentPage().getParameters().get('status');
            system.debug('status =====> ' + status); //
            String enc_response = ApexPages.currentPage().getParameters().get('encResp');
            system.debug('enc_response =====> ' + enc_response);

            Map<string, string> responsemap = CCAvenueUtilClass.decryptString(enc_response, WORKING_KEY);
        
            Utility.API_ErrorORSuccess(null, null, null, null, 'CCAvenueDynamicEventResponse', 'CCAvenueresponse', string.valueOf(responsemap));

            return null;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CCAvenueUtilClass', 'getEmployeeDetails', e , null);
            return null;

        }
    }

}