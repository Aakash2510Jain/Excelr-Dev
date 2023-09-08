public class SendNotificationToPlacementManager {
    
    @AuraEnabled(cacheable=true)
    public static List<Placement_Application__c> getPlacementApplications(Id programId) {
        return [SELECT Id, Name, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Program__c, Program__r.Name, Contact__c, Contact__r.Name, Contact__r.Email
                FROM Placement_Application__c
                WHERE Program__c = :programId AND Contact__c != null
               ];
    }
    
    
    @AuraEnabled(cacheable=true)
    public static void sendEmailToQueueMembers(String queueName, string programId) {
        try {
            if(programId != null && !String.isBlank(programId)){
                
                Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueName].Id;
                List<GroupMember> queueMembers = [SELECT UserOrGroupId, Group.Name FROM GroupMember WHERE GroupId = :queueId];
                List<String> emailAddresses = new List<String>();
                for (GroupMember member : queueMembers) {
                    emailAddresses.add(member.UserOrGroupId);
                }
                
                Program__c programRec = [SELECT Id, Name, Account__r.Name FROM Program__c WHERE Id = :programId];
                
                List<Placement_Application__c> pAppList = [SELECT Id, Name, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Program__c, Program__r.Name, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone
                                                           FROM Placement_Application__c WHERE Program__c =: programId AND Contact__c != null];
                
                String htmlBody = 'Dear ' + queueMembers[0].Group.Name + ', ';
                htmlBody += ' <br> <br> I trust this email finds you all well. I am pleased to share with you all the outcome of our recent drive at ' + programRec.Account__r.Name + '.';
                htmlBody += ' <br> Here are the results of the recent drive.';
                
                //htmlBody += '<br><br> <table border="1" style="border-collapse: collapse"><caption>Drive Result</caption><tr><th>Candidate Name</th><th>Phone</th><th>Email</th><th>Apti Marks</th><th>Apti Result</th><th>GD Result</th><th>PI Result</th></tr>';
                htmlBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Candidate Name</th><th>Phone</th><th>Email</th><th>Apti Marks</th><th>Apti Result</th><th>GD Result</th><th>PI Result</th></tr>';
                
                for(Placement_Application__c pApp : pAppList){
                    
                    String candidateName = pApp.Contact__r.Name;
                    String phone = pApp.Contact__r.Phone;
                    String email = pApp.Contact__r.Email;
                    Decimal aptiMarks = pApp.Aptitude_Marks__c;
                    String aptiResult = pApp.Aptitude_Result__c;
                    String gdResult = pApp.GD_Result__c;
                    String piResult = pApp.Personal_Interview_Result__c;
                    htmlBody += '<tr><td>' + candidateName + '</td><td>' + phone + '</td><td>' + email + '</td><td>' + aptiMarks + '</td><td>' + aptiResult + '</td><td>' + gdResult + '</td><td>' + piResult + '</td></tr>';
                }
                
                htmlBody += '</table>';
                htmlBody += '<br> With Regards';
                htmlBody += '<br> Team ExcelR';
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(emailAddresses);
                email.setSubject(programRec.Account__r.Name + ' - Drive Result');
                email.setHtmlBody(htmlBody);
                Messaging.sendEmail(new List<Messaging.Email> { email });
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException('An error occurred while sending emails: ' + e.getMessage());
        }
    }
}