public without sharing class ReferralFormController{
    /*@AuraEnabled
     public static String SubmitReferralDetails(String FirstN, String LastName, String Email, String Phone, String Coursevalue, String CID_of_Referer, String type_of_Course, String location_of_reference){
     //, String Course
     System.debug('FirstN ====> ' + FirstN);
     System.debug('LastName ====> ' + LastName);
     System.debug('Email ====> ' + Email);
     System.debug('Phone ====> ' + Phone);

     // System.debug('Course ====> ' + Course);
     string message = '';
     try{
     if (CID_of_Referer != null){
     List<Lead> LeadList = [Select id, ownerId, email, Phone
     From Lead
     where
     LIMIT 1];
     System.debug('LeadList  ====> ' + LeadList);
     if (LeadList.size() > 0){
     Lead NewLeadTobeCreated = new Lead();
     NewLeadTobeCreated.FirstName = FirstN;
     NewLeadTobeCreated.LastName = LastName;
     NewLeadTobeCreated.Email = Email;
     NewLeadTobeCreated.Phone = Phone;
     NewLeadTobeCreated.OwnerId = UserInfo.getUserId();
     NewLeadTobeCreated.CID_of_Referer__c = CID_of_Referer;
     NewLeadTobeCreated.Course__c = Coursevalue;
     NewLeadTobeCreated.Type_of_Course__c = type_of_Course;
     NewLeadTobeCreated.Referral_Email__c = LeadList[0].Email;
     NewLeadTobeCreated.Referral_Phone__c = LeadList[0].Phone;
     NewLeadTobeCreated.referrer__c = LeadList[0].id;
     NewLeadTobeCreated.LeadSource = 'Reference';
     NewLeadTobeCreated.Lead_Gen_Path__c = 'Reference';
     NewLeadTobeCreated.City__c = location_of_reference;

     insert NewLeadTobeCreated;
     System.debug('=======> ' + NewLeadTobeCreated);
     if (NewLeadTobeCreated.id != null){
     message = 'SUCCESS';
     }

     } else{
     message = 'Fail';
     }
     }
     return message;


     } catch (Exception e){
     System.debug(' the Error has occured due to =====> ' + e.getMessage());
     System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
     HandleBusinessException.captureError('ReferralFormController','SubmitReferralDetails', e, null);
     throw new AuraHandledException(e.getMessage());
     }
     }*/
    @AuraEnabled
    public static string SubmitReferralDetails(Lead Leadrec, String countrycode, string countrycodealternate){
        string message = '';
        try{

            System.debug('LeadTobeCreated =======> ' + Leadrec);
            System.debug('countrycode =======> ' + countrycode);
            System.debug('countrycodealternate =======> ' + countrycodealternate);

            list<String> NameStrings = Leadrec.LastName.split(' ');
            System.debug('NameStrings ====> ' + NameStrings);
            if (NameStrings.size() == 2){
                Leadrec.FirstName = NameStrings[0];
                Leadrec.LastName = NameStrings[1];
            } else if (NameStrings.size() == 3){
                Leadrec.FirstName = NameStrings[0];
                Leadrec.LastName = NameStrings[2];
                Leadrec.Middlename = NameStrings[1];

            }

            if (Leadrec.CID_of_Referer__c != null){
                List<Lead> LeadList = [Select id, ownerId, email, Phone
                                       From Lead
                                       where CID__c = :Leadrec.CID_of_Referer__c
                                       LIMIT 1];
                System.debug('LeadList  ====> ' + LeadList);

                leadRec.Company = Leadrec.Lastname;
                if (LeadList.size() > 0){
                    Leadrec.Referral_Email__c = LeadList[0].Email;
                    Leadrec.Referral_Phone__c = LeadList[0].Phone;
                    Leadrec.referrer__c = LeadList[0].id;
                    Leadrec.LeadSource = 'Reference';
                    Leadrec.Lead_Gen_Path__c = 'Reference';
                    Leadrec.OwnerId = UserInfo.getUserId();
                    if (countrycode != null){
                        Leadrec.Phone = countrycode + Leadrec.Phone;
                    }

                    if (countrycodealternate != null && Leadrec.Alternate_Phone__c != null){
                        Leadrec.Alternate_Phone__c = countrycodealternate + Leadrec.Alternate_Phone__c;

                    }
                    insert Leadrec;
                    if (leadRec.id != null){
                        message = 'SUCCESS';
                    }
                    else{
                        message = 'Referral CID does not found in the system';
                    }
                }


            }
        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'createLead', e, null);
            message = 'FAIL';

        }


        return message;
    }

    /*@AuraEnabled(Cacheable=true)
     public static List<string> QueryCityList(){
     List<String> CityList = new List<String>();
     try {
     List<City_State_Country__c> CityCustomSettings = [SELECT City__c,Country__c,Id,Name,State__c FROM City_State_Country__c];
     if (!CityCustomSettings.isEmpty()) {
     for (City_State_Country__c CSCs : CityCustomSettings) {
     CityList.add(CSCs.City__c);
     }
     }
     return CityList;
     } catch (Exception e) {
     throw new AuraHandledException(e.getMessage());
     }
     }*/
}