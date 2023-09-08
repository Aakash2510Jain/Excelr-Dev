public class API_WEBENGAGE_OPPORTUNITY implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext bc){
        string datevalue = system.Label.WebEngageDate;
        Date dateVal = Date.parse(dateValue);
        Date todayDate = system.today().addDays(-1); // 01/07/2023 
        return Database.getQueryLocator([SELECT Id,Name,Course__c,Phone__c,Alternate_Phone__c,Email__c,Alternate_Email__c,StageName,Pushed_to_Webengage__c,
        LID__c,Branch__c,CID__c,City__c,Country__c,Current_Domain__c,Designation__c,Enquired_Course__c,Lead_Gen_Path__c,LeadSource,Status__c,Medium__c,
        Next_follow_up_date_time__c,Organisation__c,Enter_UTM_Link__c,Qualification__c,Reason_For_Dead__c,State__c,Year_of_Experience__c,Whatsapp_Opt_in__c,
        Owner_Email__c,CreatedDate from Opportunity where CreatedDate >=: dateVal and Pushed_to_Webengage__c = false]);
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
            jsonGenerator.writeStringField('firstName', oppList[i].Name);
            
            string phone = oppList[i].Phone__c != null ? oppList[i].Phone__c : oppList[i].Alternate_Phone__c != null ?oppList[i].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());
            jsonGenerator.writeStringField('userId', phone);
            jsonGenerator.writeStringField('phone', phone);
            jsonGenerator.writeFieldName('attributes');
            jsonGenerator.writeStartObject();
            /* Some fields added */

            string Email = oppList[i].Email__c != null ? oppList[i].Email__c : 'NA';
            jsonGenerator.writeStringField('Email', Email);

            string course = oppList[i].Course__c != null ? oppList[i].Course__c : 'NA';
            jsonGenerator.writeStringField('Course', course);

            string AlternateEmail = oppList[i].Alternate_Email__c != null ? oppList[i].Alternate_Email__c : 'NA';
            jsonGenerator.writeStringField('Alternate Email', AlternateEmail);

            string AlternatePhone = oppList[i].Alternate_Phone__c != null ? oppList[i].Alternate_Phone__c : 'NA';
            jsonGenerator.writeStringField('Alternate Phone', AlternatePhone);

            string Branch = oppList[i].Branch__c != null ? oppList[i].Branch__c : 'NA';
            jsonGenerator.writeStringField('Branch', Branch);

            string CID = oppList[i].CID__c != null ? oppList[i].CID__c : 'NA';
            jsonGenerator.writeStringField('CID', CID);

            string City = oppList[i].City__c != null ? oppList[i].City__c : 'NA';
            jsonGenerator.writeStringField('City', City);

            string Country = oppList[i].Country__c != null ? oppList[i].Country__c : 'NA';
            jsonGenerator.writeStringField('Country', Country);

            string CurrentDomain = oppList[i].Current_Domain__c != null ? oppList[i].Current_Domain__c : 'NA';
            jsonGenerator.writeStringField('Current Domain', CurrentDomain);

            string Designation = oppList[i].Designation__c != null ? oppList[i].Designation__c : 'NA';
            jsonGenerator.writeStringField('Designation', Designation);

            string EnquiredCourse = oppList[i].Enquired_Course__c != null ? oppList[i].Enquired_Course__c : 'NA';
            jsonGenerator.writeStringField('Enquired Course', EnquiredCourse);

            string LID = oppList[i].LID__c != null ? oppList[i].LID__c : 'NA';
            jsonGenerator.writeStringField('LID', LID);

            string LeadGenPath = oppList[i].Lead_Gen_Path__c != null ? oppList[i].Lead_Gen_Path__c : 'NA';
            jsonGenerator.writeStringField('Lead Gen Path', LeadGenPath);

            string LeadSource = oppList[i].LeadSource != null ? oppList[i].LeadSource : 'NA';
            jsonGenerator.writeStringField('Lead Source', LeadSource);

            string LeadStatus = oppList[i].Status__c != null ? oppList[i].Status__c : 'NA';
            jsonGenerator.writeStringField('Lead Status', LeadStatus);

            string Medium = oppList[i].Medium__c != null ? oppList[i].Medium__c : 'NA';
            jsonGenerator.writeStringField('Medium', Medium);
            
            string Nextfollowupdatetime = '';
           
            if(oppList[i].Next_follow_up_date_time__c != null){
                Nextfollowupdatetime = string.valueOf(oppList[i].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            }else{
                Nextfollowupdatetime = 'NA';
            }
            system.debug('Nextfollowupdatetime---> '+Nextfollowupdatetime);

            jsonGenerator.writeStringField('Nextfollowupdatetime', Nextfollowupdatetime);
            
            string Organisation = oppList[i].Organisation__c != null ? oppList[i].Organisation__c : 'NA';
            jsonGenerator.writeStringField('Organisation', Organisation);

            string PageURL = oppList[i].Enter_UTM_Link__c != null ? oppList[i].Enter_UTM_Link__c : 'NA';
            jsonGenerator.writeStringField('Page URL', PageURL);

            string Qualification = oppList[i].Qualification__c != null ? oppList[i].Qualification__c : 'NA';
            jsonGenerator.writeStringField('Qualification', Qualification);

            string stage = oppList[i].StageName != null ? oppList[i].StageName : 'NA';
            jsonGenerator.writeStringField('Stage', stage);

            string ReasonforDead = oppList[i].Reason_For_Dead__c != null ? oppList[i].Reason_For_Dead__c : 'NA';
            jsonGenerator.writeStringField('Reason for Dead', ReasonforDead);

            string State = oppList[i].State__c != null ? oppList[i].State__c : 'NA';
            jsonGenerator.writeStringField('State', State);

            string lead_status = oppList[i].Status__c != null ? oppList[i].Status__c : 'NA';
            jsonGenerator.writeStringField('lead_status', lead_status);

            string YearsofExperience = oppList[i].Year_of_Experience__c != null ? oppList[i].Year_of_Experience__c : 'NA';
            jsonGenerator.writeStringField('Years of Experience', YearsofExperience);

            Boolean WhatsappOptin = oppList[i].Whatsapp_Opt_in__c != null;
            jsonGenerator.writeBooleanField('Whatsapp Opt in', WhatsappOptin);

            string lead_id = oppList[i].Id != null ? oppList[i].Id : 'NA';
            jsonGenerator.writeStringField('lead_id', lead_id);

            string owner = oppList[i].Owner_Email__c != null ? oppList[i].Owner_Email__c : 'NA';
            jsonGenerator.writeStringField('Lead Owner', owner);

            string Createddate = string.valueOf(oppList[i].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            jsonGenerator.writeStringField('Created Date.', Createddate);

            jsonGenerator.writeStringField('Oppurtunity Name', 'NA');
            jsonGenerator.writeStringField('Oppurtunity Owner', 'NA');
            jsonGenerator.writeStringField('Vertical', 'NA');

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
            if(!oppList.isEMpty()){
                for(Opportunity oppRec : oppList){
                    Opportunity OppRecTOUpdate = new Opportunity();
                    OppRecTOUpdate.Pushed_to_Webengage__c = true;
                    OppRecTOUpdate.Id = oppRec.Id;
                    OpprtunityListTOUpdate.add(OppRecTOUpdate);
                }          
                if(!OpprtunityListTOUpdate.isEmpty()){
                    update OpprtunityListTOUpdate;
                }
            }
        }
    }
    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing tasks or cleanup here
    }
}