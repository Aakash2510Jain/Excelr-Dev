public without sharing class ReferralFormController{
    @AuraEnabled
    public static string SubmitReferralDetails(Lead Leadrec, String countrycode, string countrycodealternate){

        if (countrycode != null && Leadrec.Phone != null){
            system.debug('Leadrec.Phone--->'+Leadrec.Phone);
            Leadrec.Phone = countrycode + Leadrec.Phone;
            system.debug('Leadrec.Phone--->'+Leadrec.Phone);
        }

        if (countrycodealternate != null && Leadrec.Alternate_Phone__c != null){
            system.debug('Leadrec.Alternate_Phone__c--->'+Leadrec.Alternate_Phone__c);
            Leadrec.Alternate_Phone__c = countrycodealternate + Leadrec.Alternate_Phone__c;
            system.debug('Leadrec.Alternate_Phone__c--->'+Leadrec.Alternate_Phone__c);
        }
        string leadem = Leadrec.Email;
        string leadaltEm = Leadrec.Alternate_Email__c;
        string leadph = '+' + Leadrec.Phone;
        string leadaltPh = '+' + Leadrec.Alternate_Phone__c;

        List<Lead> duplicateExistingLeadList = new List<Lead>();
        List<Opportunity> ExistingOppLeadList = new List<Opportunity>();
        string message = '';
        string queryStringForExistingLead = 'select Id, Email, status, course__c, CID__c,Customers__c,OwnerId,Alternate_Phone__c,Phone,Alternate_Email__c From Lead ';
        string whereclause = '';
        boolean booleanvalue = false;

        // ==========================================Opportunity Dynamic Query ===================================================
        String queryStringforOpportunityLead = 'SELECT CreatedDate,OwnerId,CID_V1__c,Alternate_Email__c,Alternate_Phone__c,Course__c,Email__c,Id,Lead_Gen_Path__c,Loan_Amount__c,Name,Phone__c,StageName FROM Opportunity where ';
        String whereClausesForOpp = '';

        System.debug('Leadrec =====> ' + Leadrec);
        try{
            if (Leadrec.Email != null){
                whereclause = ' where ( (Email = : leadem OR Alternate_Email__c =: leadem) ';
            }
            if (Leadrec.Alternate_Email__c != null && whereclause.length() > 0){
                whereclause = +whereclause + ' OR (Alternate_Email__c =: leadaltEm  OR Email =: leadaltEm) ';
            } else if (Leadrec.Alternate_Email__c != null && whereclause.length() == 0){
                whereclause = ' Where ( (Alternate_Email__c =: leadaltEm OR Email =: leadaltEm ) ';
            }
            if (Leadrec.Alternate_Phone__c != null && whereclause.length() > 0){
                whereclause = +whereclause + 'OR (Alternate_Phone__c LIKE: leadaltPh OR Phone LIKE: leadaltPh ) ';
            } else if (Leadrec.Alternate_Phone__c != null && whereclause.length() == 0){
                whereclause = ' Where ( (Alternate_Phone__c LIKE: leadaltPh  OR Phone LIKE: leadaltPh) ';
            }
            if (Leadrec.Phone != null && whereclause.length() > 0){
                whereclause = +whereclause + 'OR (Phone LIKE: leadph OR Alternate_Phone__c LIKE: leadph) ';
            } else if (Leadrec.Phone != null && whereclause.length() == 0){
                whereclause = ' Where ( (Phone LIKE: leadph OR Alternate_Phone__c LIKE: leadph) ';
            }
            if (whereclause.length() > 0){
                whereclause = + whereclause + ' )' + ' AND isconverted = false ';
            } else if (whereclause.length() == 0){
                whereclause = ' Where (isconverted = false) ';
            }
            queryStringForExistingLead = queryStringForExistingLead + whereclause;
            System.debug('queryStringForExistingLead ===> ' + queryStringForExistingLead);
            duplicateExistingLeadList = Database.query(queryStringForExistingLead);
            System.debug('duplicateExistingLeadList ====> ' + duplicateExistingLeadList);


            // ========================================= Opportunity Dynamic Query String Creation ========================================
            if (Leadrec.Email != null) {
                whereClausesForOpp = whereClausesForOpp + '( Email__c = : leadem ) ';
            }
            if (Leadrec.Alternate_Email__c != null) {
                if (!string.isBlank(whereClausesForOpp) && whereClausesForOpp.length() > 0) {
                    whereClausesForOpp = whereClausesForOpp + 'OR ( Alternate_Email__c = : leadaltEm OR Email__c =: leadaltEm ) ';
                }else {
                    whereClausesForOpp = whereClausesForOpp + ' ( Alternate_Email__c = : leadaltEm OR Email__c =: leadaltEm) ';
                }   
            }
            if (Leadrec.Phone != null) {
                if (!string.isBlank(whereClausesForOpp) && whereClausesForOpp.length() > 0) {
                    whereClausesForOpp = whereClausesForOpp + ' OR ( Phone__c LIKE : leadph OR Phone__c LIKE : leadph) ';
                }else {
                    whereClausesForOpp = whereClausesForOpp + '( Phone__c  LIKE : leadph OR Phone__c LIKE : leadph) ';
                }                
            }
            if (Leadrec.Alternate_Phone__c != null ) {
                if (!string.isBlank(whereClausesForOpp) && whereClausesForOpp.length() > 0 ) {
                    whereClausesForOpp = whereClausesForOpp + ' OR ( Alternate_Phone__c LIKE : leadaltPh OR Alternate_Phone__c LIKE: leadaltPh) ';
                    
                }else {
                    whereClausesForOpp = whereClausesForOpp + ' ( Alternate_Phone__c LIKE : leadaltPh OR Alternate_Phone__c LIKE: leadaltPh) ';
                }
            }

            queryStringforOpportunityLead = queryStringforOpportunityLead + whereClausesForOpp;
            System.debug('queryStringforOpportunityLead ===> ' + queryStringforOpportunityLead);
            ExistingOppLeadList = Database.query(queryStringforOpportunityLead);
            System.debug('ExistingOppLeadList ====> ' + ExistingOppLeadList);


            if (!duplicateExistingLeadList.isEmpty() || !ExistingOppLeadList.isEmpty()){
                message = 'Lead is already existing with Other person';

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
                    List<Lead> LeadList = [Select id, ownerId, email, Phone, CID__c
                                           From Lead
                                           where CID__c = :Leadrec.CID_of_Referer__c
                                           LIMIT 1];
                    System.debug('LeadList  ====> ' + LeadList);
                   
                    List<Opportunity> oppList = [Select Id,OwnerId,Email__c,Phone__c,CID_V1__c From Opportunity where CID_V1__c=:Leadrec.CID_of_Referer__c order by LastmodifiedDate Desc Limit 1];
                    System.debug('oppList  ====> ' + oppList);

                    leadRec.Company = Leadrec.Lastname;
                    if (LeadList.size() > 0){
                        Leadrec.Referral_Email__c = LeadList[0].Email;
                        Leadrec.Referral_Phone__c = LeadList[0].Phone;
                        Leadrec.CID_of_Referer__c = LeadList[0].CID__c;
                        Leadrec.referrer__c = LeadList[0].id;
                        Leadrec.LeadSource = 'Reference';
                        Leadrec.Lead_Gen_Path__c = 'Reference';
                        Leadrec.OwnerId = UserInfo.getUserId();
                        if (countrycode != null && Leadrec.Phone != null){
                            Leadrec.Phone = Leadrec.Phone;
                        }

                        if (countrycodealternate != null && Leadrec.Alternate_Phone__c != null){
                            Leadrec.Alternate_Phone__c = Leadrec.Alternate_Phone__c;

                        }
                        insert Leadrec;
                        if (leadRec.id != null){
                            message = 'SUCCESS';
                        }
                    } else if(oppList.size() > 0){
                        Leadrec.Referral_Email__c = oppList[0].Email__c;
                        Leadrec.Referral_Phone__c = oppList[0].Phone__c;
                        Leadrec.CID_of_Referer__c = oppList[0].CID_V1__c;
                        Leadrec.Referrer_Opportunity__c = oppList[0].id;
                        Leadrec.LeadSource = 'Reference';
                        Leadrec.Lead_Gen_Path__c = 'Reference';
                        Leadrec.OwnerId = UserInfo.getUserId();
                        if (countrycode != null && Leadrec.Phone != null){
                            Leadrec.Phone = Leadrec.Phone;
                        }
                        
                        if (countrycodealternate != null && Leadrec.Alternate_Phone__c != null){
                            Leadrec.Alternate_Phone__c = Leadrec.Alternate_Phone__c;
                            
                        }
                        insert Leadrec;
                        if (leadRec.id != null){
                            message = 'SUCCESS';
                        }
                    }else{
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
            HandleBusinessException.captureError('ReferralFormController', 'SubmitReferralDetails', e, null);
            message = 'FAIL';

        }


        return message;
    }

}