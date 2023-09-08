@RestResource(urlMapping = '/post_refer_leads')
global without sharing class API_LMSCreateReferLead {
    @HttpPost
    global static void API_LMSCreateReferLead() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- requestString' + requestString);
        List<LeadWrapper> rWrapperList = (List<LeadWrapper>) JSON.deserialize(requestString, List<LeadWrapper>.class);
        System.debug('--- rWrapperList' + rWrapperList);
        String responseBody;

        if (!rWrapperList.isEmpty()) {
            String getResponse = processLeadWrapper(rWrapperList);

            if (getResponse.startsWith('Error:')) {
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/post_refer_leads', 'POST', 400, processingStartTime, System.now(), null); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            } else {
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/post_refer_leads', 'POST', 200, processingStartTime, System.now(),null); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }

    private static String processLeadWrapper(List<LeadWrapper> leadWrapperList) {
        try {
            List<Lead> leadsToInsert = new List<Lead>();
            List<String> errors = new List<String>(); 
    
            for (LeadWrapper wrapper : leadWrapperList) {
                if (String.isBlank(wrapper.first_name)) {
                    errors.add('Error: First Name is missing or incorrect');
                }
                if (String.isBlank(wrapper.last_name)) {
                    errors.add('Error: Last Name is missing or incorrect');
                }
                if (String.isBlank(wrapper.email) || !isValidEmail(wrapper.email)) {
                    errors.add('Error: Email is missing or incorrect');
                }
                if (String.isBlank(wrapper.mobile)) {
                    errors.add('Error: Mobile is missing or incorrect');
                }
                
                // Access RefererDetails through refered_by_details
                if (String.isBlank(wrapper.refered_by_details.referrer_email)) {
                    errors.add('Error: referrer_email is missing or incorrect');
                }
                if (String.isBlank(wrapper.refered_by_details.referrer_lms_id)) {
                    errors.add('Error: referrer_lms_id is missing or incorrect');
                }
                if (String.isBlank(wrapper.refered_by_details.user_type)) {
                    errors.add('Error: user_type is missing or incorrect');
                }
                if (String.isBlank(wrapper.refered_by_details.referrer_name)) {
                    errors.add('Error: referrer_name is missing or incorrect');
                }    
                if (String.isBlank(wrapper.student_id)) {
                    errors.add('Error: student_id is missing or incorrect');
                }  
                
                if (errors.isEmpty()) {
                    Lead newLead = new Lead(
                        FirstName = wrapper.first_name,
                        LastName = wrapper.last_name,
                        Email = wrapper.email,
                        MobilePhone = wrapper.mobile,
                        Referral_Email__c = wrapper.refered_by_details.referrer_email,
                        Referral_Lms_Id__c = wrapper.refered_by_details.referrer_lms_id,
                        User_Type__c = wrapper.refered_by_details.user_type,
                        Referral_Name__c = wrapper.refered_by_details.referrer_name,
                        LMS_StudentId__c = wrapper.student_id
                    );
                    leadsToInsert.add(newLead);
                }
            }
    
            if (!leadsToInsert.isEmpty()) {
                insert leadsToInsert;
            }
    
            if (!errors.isEmpty()) {
                return String.join(errors, '\n');
            } else {
                return 'Success';
            }
        } catch (Exception e) {
            HandleBusinessException.captureError('API_LMSCreateReferLead', 'processLeadWrapper', e, null);
            return e.getMessage() + e.getLineNumber();
        }
    }

    // Custom email validation method
    private static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        return Pattern.matches(emailRegex, email);
    }

    public class LeadWrapper {
        public String first_name;
        public String last_name;
        public String email;
        public String mobile;
        public String product_interested;
        public RefererDetails refered_by_details;
        public String student_id;
    }
    
    public class RefererDetails {
        public String referrer_email;
        public String referrer_lms_id;
        public String user_type;
        public String referrer_name;
    }
}