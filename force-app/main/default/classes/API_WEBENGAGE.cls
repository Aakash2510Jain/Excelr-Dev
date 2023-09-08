public class API_WEBENGAGE implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query the records you want to process in the batch
        // Create one label and keep it as 1st of july 2023, from label it will come as string so need to change it to Date.valueOf()
        String dateValue = System.Label.WebEngageDate;
        Date dateVal = Date.parse(dateValue);
        Date todayDate = system.today(); // 01/07/2023 
        return Database.getQueryLocator([SELECT Id, Name,LastName,Course__c,Email, Alternate_Email__c,Phone,Alternate_Phone__c,Branch__c,
        CID__c,City__c,Country__c,Current_Domain__c,Designation__c,Enquired_Course__c,Lead_Gen_Path__c,LeadSource,Status,Medium__c,LID__c,Next_follow_up_date_time__c,
        Organisation__c,Enter_UTM_Link__c,Qualification__c,Reason_For_Dead__c,Owner_Email__c,State__c,Whatsapp_Opt_in__c,Year_of_Experience__c,Created_Date__c,CreatedDate FROM Lead where CreatedDate >=: dateVal and Pushed_to_Webengage__c = false]);
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
            string phone = leadList[i].Phone != null ? leadList[i].Phone : leadList[i].Alternate_Phone__c != null ?leadList[i].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());
            jsonGenerator.writeStringField('userId', phone);
            jsonGenerator.writeStringField('phone', phone);
            jsonGenerator.writeFieldName('attributes');
            jsonGenerator.writeStartObject();

            /* Some fields added */

            string course = leadList[i].Course__c != null ? leadList[i].Course__c : 'NA';
            jsonGenerator.writeStringField('Course', course);

            string Email = leadList[i].Email != null ? leadList[i].Email : 'NA';
            jsonGenerator.writeStringField('Email', Email);

            string AlternateEmail = leadList[i].Alternate_Email__c != null ? leadList[i].Alternate_Email__c : 'NA';
            jsonGenerator.writeStringField('Alternate Email', AlternateEmail);

            string AlternatePhone = leadList[i].Alternate_Phone__c != null ? leadList[i].Alternate_Phone__c : 'NA';
            jsonGenerator.writeStringField('Alternate Phone', AlternatePhone);

            string Branch = leadList[i].Branch__c != null ? leadList[i].Branch__c : 'NA';
            jsonGenerator.writeStringField('Branch', Branch);

            string CID = leadList[i].CID__c != null ? leadList[i].CID__c : 'NA';
            jsonGenerator.writeStringField('CID', CID);

            string City = leadList[i].City__c != null ? leadList[i].City__c : 'NA';
            jsonGenerator.writeStringField('City', City);

            string Country = leadList[i].Country__c != null ? leadList[i].Country__c : 'NA';
            jsonGenerator.writeStringField('Country', Country);

            string CurrentDomain = leadList[i].Current_Domain__c != null ? leadList[i].Current_Domain__c : 'NA';
            jsonGenerator.writeStringField('Current Domain', CurrentDomain);

            string Designation = leadList[i].Designation__c != null ? leadList[i].Designation__c : 'NA';
            jsonGenerator.writeStringField('Designation', Designation);

            string EnquiredCourse = leadList[i].Enquired_Course__c != null ? leadList[i].Enquired_Course__c : 'NA';
            jsonGenerator.writeStringField('Enquired Course', EnquiredCourse);

            string LID = leadList[i].LID__c != null ? leadList[i].LID__c : 'NA';
            jsonGenerator.writeStringField('LID', LID);

            string LeadGenPath = leadList[i].Lead_Gen_Path__c != null ? leadList[i].Lead_Gen_Path__c : 'NA';
            jsonGenerator.writeStringField('Lead Gen Path', LeadGenPath);

            string LeadSource = leadList[i].LeadSource != null ? leadList[i].LeadSource : 'NA';
            jsonGenerator.writeStringField('Lead Source', LeadSource);

            string LeadStatus = leadList[i].Status != null ? leadList[i].Status : 'NA';
            jsonGenerator.writeStringField('Lead Status', LeadStatus);

            string Medium = leadList[i].Medium__c != null ? leadList[i].Medium__c : 'NA';
            jsonGenerator.writeStringField('Medium', Medium);

            string Nextfollowupdatetime = string.valueOf(leadList[i].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            jsonGenerator.writeStringField('Nextfollowupdatetime', Nextfollowupdatetime);

            string Organisation = leadList[i].Organisation__c != null ? leadList[i].Organisation__c : 'NA';
            jsonGenerator.writeStringField('Organisation', Organisation);

            string PageURL = leadList[i].Enter_UTM_Link__c != null ? leadList[i].Enter_UTM_Link__c : 'NA';
            jsonGenerator.writeStringField('Page URL', PageURL);

            string Qualification = leadList[i].Qualification__c != null ? leadList[i].Qualification__c : 'NA';
            jsonGenerator.writeStringField('Qualification', Qualification);

            string ReasonforDead = leadList[i].Reason_For_Dead__c != null ? leadList[i].Reason_For_Dead__c : 'NA';
            jsonGenerator.writeStringField('Reason for Dead', ReasonforDead);

            string State = leadList[i].State__c != null ? leadList[i].State__c : 'NA';
            jsonGenerator.writeStringField('State', State);

            string lead_status = leadList[i].Status != null ? leadList[i].Status : 'NA';
            jsonGenerator.writeStringField('lead_status', lead_status);

            Boolean WhatsappOptin = leadList[i].Whatsapp_Opt_in__c != null;
            jsonGenerator.writeBooleanField('Whatsapp Opt in', WhatsappOptin);

            string YearsofExperience = leadList[i].Year_of_Experience__c != null ? leadList[i].Year_of_Experience__c : 'NA';
            jsonGenerator.writeStringField('Years of Experience', YearsofExperience);

            string lead_id = leadList[i].Id != null ? leadList[i].Id : 'NA';
            jsonGenerator.writeStringField('lead_id', lead_id);

            string owner = leadList[i].Owner_Email__c != null ? leadList[i].Owner_Email__c : 'NA';
            jsonGenerator.writeStringField('Lead Owner', owner);

            string Createddate = string.valueOf(leadList[i].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            // string Createddate = Createddate.format('yyyy-MM-dd\'T\'HH:mm:ss');
            jsonGenerator.writeStringField('Created Date.', Createddate);

            jsonGenerator.writeStringField('Oppurtunity Name', 'NA');
            jsonGenerator.writeStringField('Oppurtunity Owner', 'NA');
            jsonGenerator.writeStringField('Stage', 'NA');
            jsonGenerator.writeStringField('Vertical', 'NA');

            jsonGenerator.writeEndObject();
            jsonGenerator.writeEndObject();


        }
        
        jsonGenerator.writeEndArray();
        jsonGenerator.writeEndObject();
        
        String jsonString = jsonGenerator.getAsString();
        
        System.debug(jsonString);
        
        request.setBody(jsonString);
        HttpResponse response =  http.send(request);// http.send(request);
        //HttpResponse response = new HttpResponse();// http.send(request);
        
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
            List<Lead> leadListTOUpdate = new List<Lead>();
            
            if(!leadList.isEmpty()){
                for(Lead leadRec : leadList){
                    Lead leadRectoUpdate = new Lead();
                    leadRectoUpdate.Pushed_to_Webengage__c = true;
                    leadRectoUpdate.Id = leadRec.Id;
                    leadListTOUpdate.add(leadRectoUpdate);
                }          
                if(!leadListTOUpdate.isEmpty()){
                    update leadListTOUpdate;
                }
            }
            
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing tasks or cleanup here
    }
}