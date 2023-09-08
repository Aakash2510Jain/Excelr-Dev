@RestResource(urlMapping = '/update_device_status')
global without sharing class API_LMSUpdateDeviceStatus {

    @HttpPost
    global static void API_LMSUpdateDeviceStatus() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- requestString' + requestString);
        List<StudentInfoWrapper> studentInfoList = (List<StudentInfoWrapper>) JSON.deserialize(requestString, List<StudentInfoWrapper>.class);
        System.debug('--- studentInfoList' + studentInfoList);
        String responseBody;

        if (!studentInfoList.isEmpty()) {
            String getResponse = processStudentInfoWrapper(studentInfoList);

            if (getResponse.startsWith('Error:')) {
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_device_status', 'POST', 400, processingStartTime, System.now(),null); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            } else {
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/update_device_status', 'POST', 200, processingStartTime, System.now(),null); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }

    private static String processStudentInfoWrapper(List<StudentInfoWrapper> studentInfoList) {
        try {
            List<Contact> contactsToUpdate = new List<Contact>();
            List<String> errors = new List<String>();

            for (StudentInfoWrapper studentInfo : studentInfoList) {
                if (String.isBlank(studentInfo.student_id)) {
                    errors.add('Error: Student ID is missing');
                }
    
                if (String.isBlank(studentInfo.email)) {
                    errors.add('Error: Email is missing');
                }
    
                if (String.isBlank(studentInfo.download_status)) {
                    errors.add('Error: Download status is missing');
                }
    
                if (studentInfo.device_details == null || String.isBlank(studentInfo.device_details.device_type)) {
                    errors.add('Error: Device type is missing');
                }
    
                if (studentInfo.device_details == null || String.isBlank(studentInfo.device_details.model)) {
                    errors.add('Error: Model is missing');
                }

                // Query for the Contact record related to the provided student_id
                List<Contact> relatedContacts = [SELECT Id, LMS_Student_Id__c, Email, Download_Status__c, Device_Type__c, Model__c
                                                 FROM Contact
                                                 WHERE LMS_Student_Id__c = :studentInfo.student_id];

                if (relatedContacts.isEmpty()) {
                    errors.add('Error: No record found for student ID ' + studentInfo.student_id);
                } else {
                    Contact contact = relatedContacts[0]; // Assuming only one related record
                    contact.Email = studentInfo.email;
                    contact.Download_Status__c = studentInfo.download_status;
                    contact.Device_Type__c = studentInfo.device_details.device_type;
                    contact.Model__c = studentInfo.device_details.model;
                    contactsToUpdate.add(contact);
                }
            }

            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
            }

            if (!errors.isEmpty()) {
                return String.join(errors, '\n');
            } else {
                return 'Success';
            }
        } catch (Exception e) {
            HandleBusinessException.captureError('API_LMSUpdateDeviceStatus', 'processStudentInfoWrapper', e, null);
            return e.getMessage() + e.getLineNumber();
        }
    }

    public class StudentInfoWrapper {
        public String student_id;
        public String email;
        public String download_status;
        public DeviceDetails device_details;
    }
    
    public class DeviceDetails {
        public String device_type;
        public String model;
    }
}