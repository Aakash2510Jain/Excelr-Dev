@RestResource(urlMapping = '/LMSUpdateStudentStatus')
global with sharing class API_LMSUpdateStudentStatus {

    @HttpPost
    global static void PostLMS_UpdateStudentStatus(){
        List<Contact> studentList = new List<Contact>();
        set<Id> BlockedstudentIdset = new Set<Id>();
        set<Id> UnBlockedstudentIdset = new Set<Id>();
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);

            if (!String.isEmpty(requestString)){

                List<studentUpdateWrapper> studentBlocksList = (List<studentUpdateWrapper>) JSON.deserialize(requestString, List<studentUpdateWrapper>.class);
                 if(null !=studentBlocksList && studentBlocksList.size()>0){
                  for(studentUpdateWrapper student : studentBlocksList){
                    system.debug('student === >'+student);
                    if(student.status == 'BLOCKED'){
                        system.debug('Inside  BLOCKED ');
                      if(String.isNotBlank(student.student_id)){
                        BlockedstudentIdset.add(student.student_id);
                      }
                    }
                    else if(student.status == 'UNBLOCKED'){
                        system.debug('Inside  UNBLOCKED ');
                        if(String.isNotBlank(student.student_id)){
                            UnBlockedstudentIdset.add(student.student_id);
                          }
                    }
                  }
                  system.debug('BlockedstudentIdset === >'+UnBlockedstudentIdset);
                  system.debug('UnBlockedstudentIdset === >'+UnBlockedstudentIdset);
                 }
                // RestContext.response.responseBody =  Blob.valueOf('{ "status":"success","message": "Leads created successfully"}');
                // RestContext.response.statusCode = 200;
            } else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSUpdateStudentStatus', 'PostLMS_UpdateStudentStatus', e, null);

        }
    }



    public class studentUpdateWrapper{
        public String status;
        public String block_type;
        public Map<String, List<String>> block_details;
        public String student_id;
        public String remark;
    }
    
}