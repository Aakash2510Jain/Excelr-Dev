public without sharing class ReferralFormController{
    @AuraEnabled
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
                List<Lead> LeadList = [Select id, CID__c, ownerId, email, Phone
                                       From Lead
                                       Where CID__c = :CID_of_Referer
                                       LIMIT 1];
                System.debug('LeadList  ====> ' + LeadList);
                if (LeadList.size() > 0){
                    Lead NewLeadTobeCreated = new Lead();
                    NewLeadTobeCreated.FirstName = FirstN;
                    NewLeadTobeCreated.LastName = LastName;
                    NewLeadTobeCreated.Email = Email;
                    NewLeadTobeCreated.Phone = Phone;
                    NewLeadTobeCreated.OwnerId = UserInfo.getUserId();
                    NewLeadTobeCreated.Referral_Email__c = LeadList[0].Email;
                    NewLeadTobeCreated.Referral_Phone__c = LeadList[0].Phone;
                    NewLeadTobeCreated.referrer__c = LeadList[0].id;
                    NewLeadTobeCreated.LeadSource = 'Reference';
                    NewLeadTobeCreated.Lead_Gen_Path__c = 'Reference';

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
            throw new AuraHandledException(e.getMessage());
        }
    }

}