public class API_WEBENGAGE implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query the records you want to process in the batch
        // Create one label and keep it as 1st of july 2023, from label it will come as string so need to change it to Date.valueOf()
        String dateValue = System.Label.WebEngageDate;
        Date dateVal = Date.parse(dateValue);
        Date todayDate = system.today(); // 01/07/2023 
        return Database.getQueryLocator([SELECT Id, Name,LastName,Course__c,Email, Alternate_Email__c,Phone,Alternate_Phone__c FROM Lead where Pushed_to_Webengage__c = false and CreatedDate >: dateVal]);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> leadList) {
        
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
        system.debug('leadList.size()-->'+leadList.size());
        integer loopSize = leadList.size() <= 24 ? leadList.size() : 24;
        for (Integer i = 0; i < loopSize ; i++) {
            system.debug('leadList[i].LastName--->'+leadList[i].LastName);
            jsonGenerator.writeStartObject();
            jsonGenerator.writeStringField('firstName', leadList[i].LastName);
            string email = leadList[i].Email != null ? leadList[i].Email : leadList[i].alternate_Email__c != null ?leadList[i].alternate_Email__c : 'noEmail';
            jsonGenerator.writeStringField('email', email);
            string phone = leadList[i].Phone != null ? leadList[i].Phone : leadList[i].Alternate_Phone__c != null ?leadList[i].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());
            jsonGenerator.writeStringField('userId', phone);
            jsonGenerator.writeStringField('phone', phone);
            jsonGenerator.writeFieldName('attributes');
            jsonGenerator.writeStartObject();
            string course = leadList[i].Course__c != null ? leadList[i].Course__c : 'NA';
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
            List<Lead> leadListTOUpdate = new List<Lead>();
            
            Lead leadRec = new Lead();
            leadRec.Pushed_to_Webengage__c = true;
            leadRec.Id = leadList[0].Id;
            leadListTOUpdate.add(leadRec);
            update leadListTOUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing tasks or cleanup here
    }
}