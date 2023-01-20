/**
 * Author: Anjali Singh
 */
@RESTResource(urlMapping='/get_products/*')
global without sharing class API_ExposeProduct {
    
    /*@HttpGet
    global static void doGet() {

        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        if(!String.isEmpty(requestString)) {
            /*Project__c newProject = (Project__c)JSON.deserialize(requestString, Project__c.class);
            if(newProject != null) {
                //system.debug('insertLead :: ' + insertLead(leadWrapper));
                String projectId = updateProject(newProject);
                if(projectId != null)
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationResponseWrapper.APIResponseWrapper('Success', 'Project updated succesfully:'+projectId)));
                else
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationResponseWrapper.APIResponseWrapper('Error', 'Could not update Project')));
            }
        }else {
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationResponseWrapper.APIResponseWrapper('Error', 'Bad Request')));
            RestContext.response.statusCode = 400;
        }
    }*/

    @HttpGet
    global static List<PricebookEntry> getAllProducts(){
        try {
            List<PricebookEntry> pbeList= [SELECT UnitPrice, Product2.Name, Product2.ProductCode, Product2.Family, Product2.IsActive, Product2.Description FROM PricebookEntry];
            return pbeList;
        }catch(Exception e){
            System.debug(' --- Error Msg '+ e.getMessage());
            System.debug(' --- Error LineNo '+ e.getLineNumber());
           HandleBusinessException.captureError('API_ExposeProduct','getAllProducts', e, null);
            return null;
        }
    }
    
    public class ProductWrapper{
        public List<Product2> allProds;
        public Decimal ListPrice;
    }
    
}