public without sharing class ReferralFormController{
    @AuraEnabled
    public static string SubmitReferralDetails(Lead Leadrec, String countrycode, string countrycodealternate){

        if (countrycode != null && Leadrec.Phone != null){
            Leadrec.Phone = countrycode + Leadrec.Phone;
        }

        if (countrycodealternate != null && Leadrec.Alternate_Phone__c != null){
            Leadrec.Alternate_Phone__c = countrycodealternate + Leadrec.Alternate_Phone__c;

        }
        string leadem = Leadrec.Email;
        string leadaltEm = Leadrec.Alternate_Email__c;
        string leadph = Leadrec.Phone;
        string leadaltPh = Leadrec.Alternate_Phone__c;

        List<Lead> duplicateExistingLeadList = new List<Lead>();
        string message = '';
        string queryStringForExistingLead = 'select Id, Email, status, course__c, CID__c,Customers__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead ';
        string whereclause = '';
        boolean booleanvalue = false;

        System.debug('Leadrec =====> ' + Leadrec);
        try{
            if (Leadrec.Email != null){
                whereclause = ' where ( (Email = : leadem) ';
            }
            if (Leadrec.Alternate_Email__c != null && whereclause.length() > 0){
                whereclause = +whereclause + ' OR (Alternate_Email__c =: leadaltEm) ';
            } else if (Leadrec.Alternate_Email__c != null && whereclause.length() == 0){
                whereclause = 'Where ( (Alternate_Email__c =: leadaltEm) ';
            }
            if (Leadrec.Alternate_Phone__c != null && whereclause.length() > 0){
                whereclause = +whereclause + 'OR (Alternate_Phone__c =: leadaltPh) ';
            } else if (Leadrec.Alternate_Phone__c != null && whereclause.length() == 0){
                whereclause = 'Where ( (Alternate_Phone__c =: leadaltPh) ';
            }
            if (Leadrec.Phone != null && whereclause.length() > 0){
                whereclause = +whereclause + 'OR (Phone =: leadph) ';
            } else if (Leadrec.Phone != null && whereclause.length() == 0){
                whereclause = 'Where ( (Phone =: leadph) ';
            }
            if (whereclause.length() > 0){
                whereclause = +whereclause + ' )' + ' AND isconverted = false ';
            } else if (whereclause.length() == 0){
                whereclause = ' Where (isconverted =: false) ';
            }
            queryStringForExistingLead = queryStringForExistingLead + whereclause;
            System.debug('queryStringForExistingLead ===> ' + queryStringForExistingLead);
            duplicateExistingLeadList = Database.query(queryStringForExistingLead);
            System.debug('duplicateExistingLeadList ====> ' + duplicateExistingLeadList);

            if (!duplicateExistingLeadList.isEmpty()){
                message = 'lead is already existing with Other person';

            } else{
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
                        if (countrycode != null && Leadrec.Phone != null){
                            Leadrec.Phone = countrycode + Leadrec.Phone;
                        }

                        if (countrycodealternate != null && Leadrec.Alternate_Phone__c != null){
                            Leadrec.Alternate_Phone__c = countrycodealternate + Leadrec.Alternate_Phone__c;

                        }
                        insert Leadrec;
                        if (leadRec.id != null){
                            message = 'SUCCESS';
                        }
                    } else{
                        message = 'Referral CID does not found in the system';
                    }
                } else{
                    message = 'Please Provide Referrer CID!!!!';
                }

            }

        } 
        catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'createLead', e, null);
            message = 'FAIL';

        }


        return message;
    }

}