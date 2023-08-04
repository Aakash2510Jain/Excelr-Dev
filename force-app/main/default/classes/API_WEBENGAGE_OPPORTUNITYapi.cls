public class API_WEBENGAGE_OPPORTUNITYapi implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext bc){
        string datevalue = system.Label.WebEngageDate;
        Date dateVal = Date.parse(dateValue);
        Date todayDate = system.today(); // 01/07/2023 
        return Database.getQueryLocator([SELECT Id,Name,Course__c,Phone__c,Alternate_Phone__c,Email__c,Alternate_Email__c from Opportunity where Pushed_to_Webengage__c	= false and CreatedDate >: dateVal]);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> oppList){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(' https://api.webengage.com/v1/accounts/~15ba20116/bulk-users');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer 1312f51b-498a-46cd-8cc2-d16ce6bf7c9e');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        JSONGenerator jsonGenerator = JSON.createGenerator(true);
        jsonGenerator.writeStartObject();
        jsonGenerator.writeFieldName('users');
        jsonGenerator.writeStartArray();
        system.debug('oppList.size()-->'+oppList.size());
        integer loopSize = oppList.size() <= 24 ? oppList.size() : 24;
        for (Integer i = 0; i < loopSize ; i++){
            system.debug('oppList[i].Name--->'+oppList[i].Name);
            jsonGenerator.writeStartObject();
            jsonGenerator.writeStringField('Name', oppList[i].Name);
            string email = oppList[i].Email__c != null ? oppList[i].Email__c : oppList[i].Alternate_Email__c != null ?oppList[i].Alternate_Email__c : 'noEmail';
            jsonGenerator.writeStringField('email', email);
            string phone = oppList[i].Phone__c != null ? oppList[i].Phone__c : oppList[i].Alternate_Phone__c != null ?oppList[i].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());
            jsonGenerator.writeStringField('userId', phone);
            jsonGenerator.writeStringField('phone', phone);
            jsonGenerator.writeFieldName('attributes');
            jsonGenerator.writeStartObject();
            string course = oppList[i].Course__c != null ? oppList[i].Course__c : 'NA';
            jsonGenerator.writeStringField('Course', course);
            jsonGenerator.writeEndObject();
            jsonGenerator.writeEndObject();
        }
        jsonGenerator.writeEndArray();
        jsonGenerator.writeEndObject();
        
        String jsonString = jsonGenerator.getAsString();
        
        System.debug(jsonString);
        
        request.setBody(jsonString);
        HttpResponse response = http.send(request);
        
        
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
            List<Opportunity> OpprtunityListTOUpdate = new List<Opportunity>();
            
            Opportunity OppRec = new Opportunity();
            OppRec.Pushed_to_Webengage__c = true;
            OppRec.Id = oppList[0].Id;
            OpprtunityListTOUpdate.add(OppRec);
            update OpprtunityListTOUpdate;
        }
    }
    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing tasks or cleanup here
    }
}