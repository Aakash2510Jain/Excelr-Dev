@RestResource(urlMapping='/Account/*')
global without sharing class MyRestResource {
    @HttpGet
    global static Account doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Account result = [SELECT Id, Name, Phone, Website FROM Account limit 1];
        return result;
    }
}