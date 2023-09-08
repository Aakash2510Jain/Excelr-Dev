@RestResource(urlMapping = '/post_support_ticket')
global without sharing class API_LMSCreateSupportTicket {

    @HttpPost
    global static void API_LMSCreateSupportTicket() {
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- requestString' + requestString);
        List<TicketWrapper> rWrapperList = (List<TicketWrapper>) JSON.deserialize(requestString, List<TicketWrapper>.class);
        System.debug('--- rWrapperList' + rWrapperList);
        String responseBody;

        if (!rWrapperList.isEmpty()) {
            String getResponse = processTicketRequest(rWrapperList);

            if (getResponse.startsWith('Error:')) {
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/post_support_ticket', 'POST', 400, processingStartTime, System.now(),null); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            } else {
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/post_support_ticket', 'POST', 200, processingStartTime, System.now(),null); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }

   private static String processTicketRequest(List<TicketWrapper> ticketWrapperList) {
    try {
        System.debug('ticketWrapperList ==> ' + ticketWrapperList);
        Set<String> setOfLmsStudentId = new Set<String>();

        for (TicketWrapper ticket : ticketWrapperList) {
            setOfLmsStudentId.add(ticket.student_id);
        }

        Map<String, Contact> studentIdToContactMap = new Map<String, Contact>();
        for (Contact contact : [SELECT Id, LMS_Student_Id__c, Email, Name FROM Contact WHERE LMS_Student_Id__c IN :setOfLmsStudentId]) {
            studentIdToContactMap.put(contact.LMS_Student_Id__c, contact);
        }

        List<Case> casesToInsert = new List<Case>();
        List<String> errors = new List<String>(); // To hold error messages

        for (TicketWrapper ticket : ticketWrapperList) {
            if (!studentIdToContactMap.containsKey(ticket.student_id)) {
                errors.add('Error: Student ID not found for ' + ticket.student_id);
                continue; // Skip the rest of the loop for this iteration
            }

            Case newCase = new Case();
            newCase.LMS_Case_Id__c = ticket.ticket_id;
            newCase.Ticket_Number__c = ticket.ticket_number;
            newCase.Subject = ticket.subject;
            newCase.Description = ticket.description;
            newCase.Category__c = ticket.category;

            Contact relatedContact = studentIdToContactMap.get(ticket.student_id);

            // Validate Contact Name and Email
            if (!String.isEmpty(ticket.contact_name) && relatedContact.Name != ticket.contact_name) {
                errors.add('Error: Contact Name mismatch for student ID ' + ticket.student_id);
                continue; // Skip the rest of the loop for this iteration
            }
            if (!String.isEmpty(ticket.contact_email) && relatedContact.Email != ticket.contact_email) {
                errors.add('Error: Contact Email mismatch for student ID ' + ticket.student_id);
                continue; // Skip the rest of the loop for this iteration
            }

            newCase.ContactId = relatedContact.Id;
            casesToInsert.add(newCase);
        }

        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;

           
                // Now that cases are inserted, we can insert attachments
                List<Case_Attachment__c> attachmentsList = new List<Case_Attachment__c>();
                for (Integer i = 0; i < casesToInsert.size(); i++) {
                    Case newCase = casesToInsert[i];
                    for (String attachmentUrl : ticketWrapperList[i].attachments) {
                        Case_Attachment__c attachment = new Case_Attachment__c();
                        attachment.Case__c = newCase.Id; // Assign the Case Id now
                        attachment.Attachment_Url__c = attachmentUrl;
                        attachmentsList.add(attachment);
                    }
                }
                
                if (!attachmentsList.isEmpty()) {
                    insert attachmentsList;
                }
        }

        if (!errors.isEmpty()) {
            return String.join(errors, '\n');
        } else {
            return 'Case is successfully generated for all the Student IDs';
        }
    } catch (Exception e) {
        HandleBusinessException.captureError('API_LMSCreateSupportTicket', 'processTicketRequest', e, null);
        return e.getMessage() + e.getLineNumber();
    }
}


    public class TicketWrapper {
        public String ticket_id;
        public String ticket_number;
        public String subject;
        public String student_id;
        public String contact_name;
        public String contact_email;
        public String description;
        public String category;
        public List<String> attachments;
    }
}