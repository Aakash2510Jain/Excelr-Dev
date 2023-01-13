public without sharing class ReferralFormController {
    
    @AuraEnabled
    public static String SubmitReferralDetails(String FirstN, String LastName, String Email, String Phone, String ReferralEm, String ReferralPh){ //, String Course
        System.debug('FirstN ====> ' + FirstN);
        System.debug('LastName ====> ' + LastName);
        System.debug('Email ====> ' + Email);
        System.debug('Phone ====> ' + Phone);
        System.debug('ReferralEmail ====> ' + ReferralEm);
        System.debug('ReferralPhone ====> ' + ReferralPh);
       // System.debug('Course ====> ' + Course);
        string message= '';
        try {
            if (ReferralEm != null) {
                List<Lead> LeadList = [Select id, ownerId, email From Lead Where Email =:ReferralEm LIMIT 1];
                System.debug('LeadList  ====> ' + LeadList);
                if (LeadList.size() >0) {
                    Lead NewLeadTobeCreated = new Lead();
                    NewLeadTobeCreated.FirstName = FirstN;
                    NewLeadTobeCreated.LastName = LastName;
                    NewLeadTobeCreated.Email = Email;
                    NewLeadTobeCreated.Phone = Phone;
                    NewLeadTobeCreated.OwnerId = LeadList[0].OwnerId;
                    NewLeadTobeCreated.Referral_Email__c = ReferralEm;
                    NewLeadTobeCreated.Referral_Phone__c = ReferralPh;
                    NewLeadTobeCreated.referrer__c = LeadList[0].id;
                    insert NewLeadTobeCreated;
                    System.debug('=======> ' + NewLeadTobeCreated);
                    if (NewLeadTobeCreated.id != null) {
                        message = 'SUCCESS'; 
                    }

                }
                else{
                    message = 'Fail'; 
                }
            }
            return message;

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}