public class InterviewResultCSVUploadController {
    
    @AuraEnabled
    public static void processData(String fileData,String sobjectName,List<String> fields, String recordId){
        system.debug('fileData-------------------->'+fileData);
        system.debug('sobjectName----------------->'+sobjectName);
        system.debug('fileData-------------------->'+fields);
        system.debug('recordId-------------------->'+recordId);
        
        map<String,String> apiNameByLabelName 					    = new map<String,String>();
        map<String,String> internalAppIdsByName					    = new map<String,String>();
        //map<String,String> internalAppIdsByintIds					    = new map<String,String>();
        Map<String, Placement_Application__c> intApplicationMap 	= new Map<String, Placement_Application__c>();
        List<Placement_Application__c> intApplicationList		    = new List<Placement_Application__c>();
        
        intApplicationList = [Select Id, Name, Aptitude_Result__c, Aptitude_Marks__c, GD_Result__c,Opportunity__c, Contact__c, Contact__r.Internal_Student_Id__c, Contact__r.LMS_Student_Id__c 
                              from Placement_Application__c where Opportunity__c =: recordId];
        
        List<Id> internalStudentIds = new List<Id>();
        List<Id> LMSstudentIds = new List<Id>();
        
        for(Placement_Application__c intAppObj : intApplicationList) {
            internalAppIdsByName.put(intAppObj.Name,intAppObj.Id);
        }
        
        List<Upload_Interview_Results__mdt> uploadCSVFileFormat = [SELECT Field_API_Name__c,Id,Label,Sequence__c FROM Upload_Interview_Results__mdt];
        
        for(Upload_Interview_Results__mdt upcsv : uploadCSVFileFormat) {
            apiNameByLabelName.put(upcsv.Label,upcsv.Field_API_Name__c);
        }       
        
        List<Placement_Application__c> recordList = new List<Placement_Application__c>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectName);
        
        try{
            if(fileData!=null) { 
                String[] fileLines = new String[]{};
                    fileLines = fileData.split('\n');
                //for content
                
                system.debug('fileLines.size()'+fileLines.size());
                for (Integer i=1,j=fileLines.size();i<j;i++){
                    
                    String[] inputvalues = new String[]{};
                        inputvalues = fileLines[i].split(',');
                    
                    sObject obj = targetType.newSObject();
                    integer rowsize=inputvalues.size(); 
                    system.debug('rowsize.size()'+rowsize);
                    for(integer l=0;l<rowsize;l++){      
                        if(String.isNotBlank(inputvalues[l])) {
                            String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                            
                            if(fields.get(l) == 'Application Id'){
                                if( internalAppIdsByName.containsKey(value)){
                                    obj.put('Id',internalAppIdsByName.get(value));
                                }else{
                                    throw new CustomException('Application Id is mandatory');
                                }  
                            }
                            else if(fields.get(l) == 'Aptitude Marks'){
                                obj.put(apiNameByLabelName.get(fields.get(l)),decimal.valueOf(value));
                            }
                            else if(fields.get(l) == 'Aptitude Result'){
                                obj.put(apiNameByLabelName.get(fields.get(l)),value);
                            }
                            else if(fields.get(l) == 'GD Result'){
                                obj.put(apiNameByLabelName.get(fields.get(l)),value);  
                            }
                        }
                    }
                    if(obj.Id != null){
                        recordList.add((Placement_Application__c)obj);    
                    }
                    
                }
                if (recordList.size() > 0) { 
                    update recordList;
                }
            }
            
        }
        catch(Exception e){
              system.debug('Exception @ '+e.getLineNumber());
                throw new CustomException(e.getMessage());
            }
        }
        
    }