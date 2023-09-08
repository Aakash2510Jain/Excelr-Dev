/*
* Author : Shubhi & Anjali
*/

public class InterviewResultCSVUploadController {
    
    @AuraEnabled
    public static void uploadAptiResult(String fileData,String sobjectName,List<String> fields, String recordId){
        try{
            Program__c programRec = [SELECT Id, Sub_Stage__c,Account__c, Program_Start_Date_Time__c, Aptitude_Test_Date_Time__c, GD_Date_Time__c, Personal_Interview_Date_Time__c FROM Program__c WHERE Id =: recordId];
            programRec.Sub_Stage__c = 'Aptitude Result Declared';
            update programRec;
            
            processData(fileData, sobjectName, fields, recordId, false);
           // sendEmailToPlacementDriveTeam(programRec.Account__c,programRec.Aptitude_Test_Date_Time__c,'Apti');
              sendEmailForuploadAptiResult(programRec.Account__c,programRec.Aptitude_Test_Date_Time__c,'Apti',programRec.Id);
              
        }
        catch(Exception e){
            system.debug('uploadAptiResult ERROR -- ' + e.getMessage());
            system.debug('LINE NO -- ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static void uploadGDResult(String fileData,String sobjectName,List<String> fields, String recordId){
        try{
            Program__c programRec = [SELECT Id, Sub_Stage__c,Account__c, Program_Start_Date_Time__c, Aptitude_Test_Date_Time__c, GD_Date_Time__c, Personal_Interview_Date_Time__c FROM Program__c WHERE Id =: recordId];
            programRec.Sub_Stage__c = 'GD Result Declared';
            update programRec;
            
            processData(fileData, sobjectName, fields, recordId, false);
          //  sendEmailToPlacementDriveTeam(programRec.Account__c,programRec.GD_Date_Time__c,'GD');
              sendEmailForuploadAptiResult(programRec.Account__c,programRec.Aptitude_Test_Date_Time__c,'GD',programRec.Id);
        }
        catch(Exception e){
            system.debug('uploadGDResult ERROR -- ' + e.getMessage());
            system.debug('LINE NO -- ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static void uploadPIResult(String fileData, String sobjectName, List<String> fields, String recordId){
        try{
            Program__c programRec = [SELECT Id, Sub_Stage__c,Account__c, Program_Start_Date_Time__c, Aptitude_Test_Date_Time__c, GD_Date_Time__c, Personal_Interview_Date_Time__c FROM Program__c WHERE Id =: recordId];
            programRec.Sub_Stage__c = 'PI Result Declared';
            update programRec;
            
            processData(fileData, sobjectName, fields, recordId, true);
          //  sendEmailToPlacementDriveTeam(programRec.Account__c,programRec.Personal_Interview_Date_Time__c,'PI');
             sendEmailForuploadAptiResult(programRec.Account__c,programRec.Aptitude_Test_Date_Time__c,'PI',programRec.Id);
        }
        catch(Exception e){
            system.debug('uploadPIResult ERROR -- ' + e.getMessage());
            system.debug('LINE NO -- ' + e.getLineNumber());
        }
    }
     
     @AuraEnabled
    public Static void sendEmailForuploadAptiResult(ID accountIds,Datetime scheduleTime, String interviewType,String programId){

          System.debug('accountIds------>'+accountIds);
          System.debug('scheduleTime------>'+scheduleTime);
           System.debug('interviewType------>'+interviewType);
          System.debug('programId------>'+programId);


        
        try{
             if(programId != null && !String.isBlank(programId)){
                 
                    List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
                    System.debug('conEmaiList---->'+accountIds);
                    List<String> conEmaiList = new List<String>();
                    Program__c programRec = [SELECT Id, Name, Account__r.Name FROM Program__c WHERE Id = :programId];
                    List<Contact> contactList = [SELECT ID, Name,LastName,FirstName, Email FROM Contact where AccountId =:accountIds and Designation__c ='Placement Officer']; 

                    System.debug('contactList---->'+contactList);
                 
                     List<Placement_Application__c> pAppList = [SELECT Id, Name, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Program__c, Program__r.Name, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone
                                    FROM Placement_Application__c WHERE Program__c =: programId AND Contact__c != null];

                    string htmlBody =  'Dear ' + contactList[0].Name + ', ';
                    htmlBody += ' <br> <br> I trust this email finds you all well. I am pleased to share with you all the outcome of our recent drive at ' + programRec.Account__r.Name + '.';
                    htmlBody += ' <br> Here are the results of the recent drive.';
                 //   htmlBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Candidate Name</th><th>Phone</th><th>Email</th><th>Apti Marks</th><th>Apti Result</th><th>GD Result</th><th>PI Result</th></tr>';
                     if(interviewType == 'Apti'){
                      htmlBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Candidate Name</th><th>Phone</th><th>Email</th><th>Apti Marks</th><th>Apti Result</th></tr>';  //<th>GD Result</th><th>PI Result</th></tr>';
                     }else if(interviewType == 'GD'){
                       htmlBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Candidate Name</th><th>Phone</th><th>Email</th><th>Apti Marks</th><th>Apti Result</th><th>GD Result</th></tr>';  //<th>PI Result</th></tr>';
                     }else{
                          htmlBody += '<br><br> <table border="2" style="border-collapse: collapse"><tr><th>Candidate Name</th><th>Phone</th><th>Email</th><th>Apti Marks</th><th>Apti Result</th><th>GD Result</th><th>PI Result</th></tr>';
                     }
                 for(Placement_Application__c pApp : pAppList){
            
                    String candidateName = pApp.Contact__r.Name;
                    String phone = pApp.Contact__r.Phone;
                    String email = pApp.Contact__r.Email;
                    Decimal aptiMarks = pApp.Aptitude_Marks__c;
                    String aptiResult = pApp.Aptitude_Result__c;
                    String gdResult = pApp.GD_Result__c;
                    String piResult = pApp.Personal_Interview_Result__c;
                    if(interviewType == 'Apti'){
                                htmlBody += '<tr><td>' + candidateName + '</td><td>' + phone + '</td><td>' + email + '</td><td>' + aptiMarks + '</td><td>' + aptiResult + '</td></tr>' ; // <td>' + gdResult + '</td><td>' + piResult + '</td></tr>';
                    }else if(interviewType == 'GD'){
                            htmlBody += '<tr><td>' + candidateName + '</td><td>' + phone + '</td><td>' + email + '</td><td>' + aptiMarks + '</td><td>' + aptiResult + '</td><td>' + gdResult + '</td></tr>' ; //<td>' + piResult + '</td></tr>';
                    }else{
                          htmlBody += '<tr><td>' + candidateName + '</td><td>' + phone + '</td><td>' + email + '</td><td>' + aptiMarks + '</td><td>' + aptiResult + '</td><td>' + gdResult + '</td><td>' + piResult + '</td></tr>';
                    }
                    
                }  
                  htmlBody += '</table>';
                  htmlBody += '<br> With Regards';
                  htmlBody += '<br> Team ExcelR';
                  //  for(Contact conRec:contactList){
                        
                    if(contactList[0].Email !=null){
                        System.debug('contactList[0].Email---->'+contactList[0].Email);
                        Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                        mymail.setToAddresses(new string[] {contactList[0].Email} );  //conEmaiList
                        mymail.setSenderDisplayName('Excelr');
                        mymail.setSubject('Placement Drive');
                        mymail.setSaveAsActivity(false);    
                          mymail.setHtmlBody(htmlBody);
                        semList.add(mymail);
                    }
            //    }     
                      Messaging.sendEmail(semList);         
             }   
            
            
            
        }catch(Exception e){
            system.debug('Exception mEssage---->'+e.getMessage());
            System.debug('Exception Line Number--->'+e.getLineNumber());
        }
        
        
        
    }
    
    @AuraEnabled
    public static void sendEmailToPlacementDriveTeam(ID accountIds,Datetime scheduleTime, String interviewType ){
        List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
        System.debug('conEmaiList---->'+accountIds);
        List<String> conEmaiList = new List<String>();
        List<Contact> contactList = [SELECT ID, Name,LastName,FirstName, Email FROM Contact where AccountId =:accountIds and Designation__c ='Placement Officer']; 
        for(Contact conRec:contactList){
            if(conRec.Email !=null){
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(new string[] {conRec.Email} );  //conEmaiList
                mymail.setSenderDisplayName('Excelr');
                mymail.setSubject('Placement Drive');
                mymail.setSaveAsActivity(false);
                if(interviewType == 'Apti'){
                    mymail.setPlainTextBody('Hello ,'+conRec.LastName +'' +'\n'+'\n' + 'I trust this email finds you in good health. I am writing to discuss the possibility of conducting a placement drive at Your College for our graduating students  Aptitude Test On.'+scheduleTime +'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                }
                else if(interviewType == 'GD'){
                    mymail.setPlainTextBody('Hello ,'+conRec.LastName +'' +'\n'+'\n' + 'I trust this email finds you in good health. I am writing to discuss the possibility of conducting a placement drive at Your College for our graduating students  GROUP DESCUSSION  On.'+scheduleTime +'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                } 
                else{                    
                    mymail.setPlainTextBody('Hello ,'+conRec.LastName +'' +'\n'+'\n' + 'I trust this email finds you in good health. I am writing to discuss the possibility of conducting a placement drive at Your College for our graduating students  Personal Interview On.'+scheduleTime +'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                }
                semList.add(mymail);
            }
        }     
        Messaging.sendEmail(semList);
    }
    
    private static void processData(String fileData, String sobjectName, List<String> fields, String recordId, Boolean isPIResult){
        system.debug('fileData-------------------->'+fileData);
        system.debug('sobjectName----------------->'+sobjectName);
        system.debug('fields-------------------->'+fields);
        system.debug('recordId-------------------->'+recordId);
        system.debug('isPIResult-------------------->'+isPIResult);
        
        map<String,String> apiNameByLabelName 					    = new map<String,String>();
        map<String,String> internalAppIdsByName					    = new map<String,String>();
        //map<String,String> internalAppIdsByintIds					    = new map<String,String>();
        Map<String, Placement_Application__c> intApplicationMap 	= new Map<String, Placement_Application__c>();
        List<Placement_Application__c> intApplicationList		    = new List<Placement_Application__c>();
        
        intApplicationList = [Select Id, Name, Aptitude_Result__c, Aptitude_Marks__c, GD_Result__c, Program__c, Contact__c, Contact__r.Internal_Student_Id__c, Contact__r.LMS_Student_Id__c 
                              from Placement_Application__c where Program__c =: recordId];
        
        List<Id> internalStudentIds = new List<Id>();
        List<Id> LMSstudentIds = new List<Id>();
        
        for(Placement_Application__c intAppObj : intApplicationList) {
            internalAppIdsByName.put(intAppObj.Name,intAppObj.Id);
        }
        
        List<Upload_Interview_Results__mdt> uploadCSVFileFormat = [SELECT Field_API_Name__c,Id,Label,Sequence__c FROM Upload_Interview_Results__mdt];
        
        for(Upload_Interview_Results__mdt upcsv : uploadCSVFileFormat) {
            apiNameByLabelName.put(upcsv.Label, upcsv.Field_API_Name__c);
        }       
        
        List<Placement_Application__c> recordList = new List<Placement_Application__c>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectName);
        List<Placement_Application__c> piPassedRecordList = new List<Placement_Application__c>();
        List<Placement_Application__c> failedRecordList = new List<Placement_Application__c>();
        
        set<Id> appIdSet = new set<Id>();
        
        try{
            if(fileData!=null) { 
                String[] fileLines = new String[]{};
                    fileLines = fileData.split('\n');
                
                system.debug('fileLines.size()'+fileLines.size());
                for (Integer i=1, j=fileLines.size(); i<j; i++){
                    
                    String[] inputvalues = new String[]{};
                        inputvalues = fileLines[i].split(',');
                    
                    system.debug('inputvalues' + inputvalues);
                    sObject obj = targetType.newSObject();
                    integer rowsize=inputvalues.size(); 
                    system.debug('rowsize.size()'+rowsize);
                    
                    for(integer l=0; l<rowsize; l++){      
                        if(String.isNotBlank(inputvalues[l])) {
                            String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                            
                            if(fields.get(l) == 'Application_Id'){
                                if( internalAppIdsByName.containsKey(value)){
                                    obj.put('Id',internalAppIdsByName.get(value));
                                }else{
                                    throw new CustomException('Application Id is mandatory');
                                }  
                            }
                            else if(fields.get(l) == 'Apti_Marks'){
                                obj.put(apiNameByLabelName.get(fields.get(l)),decimal.valueOf(value));
                            }
                            else if(fields.get(l) == 'Apti_Result'){
                                if(value.containsIgnoreCase('Fail') || string.isBlank(value) || value == '' || value == null){
                                    system.debug('obj -- ' + obj);
                                    failedRecordList.add((Placement_Application__c)obj);
                                    system.debug('failedRecordList -- ' + failedRecordList);
                                }
                                obj.put(apiNameByLabelName.get(fields.get(l)),value);
                            }
                            else if(fields.get(l) == 'GD_Result'){
                                if(value.containsIgnoreCase('Fail') || string.isBlank(value) || value == '' || value == null){
                                    system.debug('obj -- ' + obj);
                                    failedRecordList.add((Placement_Application__c)obj);
                                    system.debug('failedRecordList -- ' + failedRecordList);
                                }
                                obj.put(apiNameByLabelName.get(fields.get(l)),value);  
                            }
                            else if(fields.get(l) == 'PI_Result'){
                                system.debug('Pass -- ' + value);
                                
                                if(value.containsIgnoreCase('Pass') ){
                                    system.debug('obj -- ' + obj);
                                    piPassedRecordList.add((Placement_Application__c)obj);
                                    system.debug('piPassedRecordList -- ' + piPassedRecordList);
                                }
                                else if(value.containsIgnoreCase('Fail') || string.isBlank(value) || value == '' || value == null){
                                    system.debug('obj -- ' + obj);
                                    failedRecordList.add((Placement_Application__c)obj);
                                    system.debug('failedRecordList -- ' + failedRecordList);
                                }
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
                
                if(isPIResult && piPassedRecordList.size()>0){
                    set<Id> pAppIdSet = new set<Id>();
                    for(Placement_Application__c pApp : piPassedRecordList){
                        pAppIdSet.add(pApp.Id);
                    }
                    createOpportunity(pAppIdSet);
                }
                
                if(failedRecordList.size()>0){
                    set<Id> pAppIdSet = new set<Id>();
                    for(Placement_Application__c pApp : failedRecordList){
                        pAppIdSet.add(pApp.Id);
                    }
                    createLead(pAppIdSet);
                }
            }
            
        }
        catch(Exception e){
            system.debug('Exception @ '+e.getLineNumber());
            throw new CustomException(e.getMessage());
        }
    }
    
    private static void createLead(set<Id> pAppIdSet){
        try{
            system.debug('pAppIdSet -- ' + pAppIdSet);
            List<Placement_Application__c> placementAppList = [SELECT Id, Program__r.Name, Name, Aptitude_Result__c, Aptitude_Marks__c, GD_Result__c, Program__c, Contact__r.Phone, Contact__c,Contact__r.Email, Contact__r.Internal_Student_Id__c, Contact__r.LMS_Student_Id__c 
                                                               FROM Placement_Application__c where Id IN: pAppIdSet AND Lead_Created__c = FALSE];
            system.debug('placementAppList -- ' + placementAppList);
            
            List<Program_Product__c> programProdList = [SELECT Id, Product__c FROM Program_Product__c WHERE Program__c =: placementAppList[0].Program__c];
            set<Id> prodIdSet = new set<Id>();
            for(Program_Product__c pProd : programProdList){
                prodIdSet.add(pProd.Product__c);
            }
            
            system.debug('prodIdSet  -- ' + prodIdSet);
            
            List<Lead> ldListToBeInserted = new List<Lead>();
            Id retailLdRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail').getRecordTypeId();
            
            for(Placement_Application__c appRec : placementAppList){
                appRec.Lead_Created__c = TRUE;
                
                Lead ld = new Lead();
                ld.FirstName = appRec.Contact__r.LMS_Student_Id__c != null ? appRec.Contact__r.LMS_Student_Id__c : '';
                ld.LastName = placementAppList[0].Program__r.Name;
                ld.Status = 'New';
                ld.Email = appRec.Contact__r.Email;
                ld.Phone = appRec.Contact__r.Phone;
                ld.LMS_StudentId__c = appRec.Contact__r.LMS_Student_Id__c;
                ld.RecordTypeId = retailLdRecordTypeId;
                ld.Placement_Application__c = appRec.Id;
                ldListToBeInserted.add(ld);
            }
                        
            if(ldListToBeInserted.size()>0){
                update placementAppList;
                Database.insert(ldListToBeInserted,true);
                List<Product_Interested__c> prodInterestList = new List<Product_Interested__c>();
                
                for(Lead ld : ldListToBeInserted){
                    for(Id prodId : prodIdSet){
                        Product_Interested__c pIntRec = new Product_Interested__c();
                        pIntRec.Product__c = prodId;
                        pIntRec.Lead__c = ld.Id;
                        prodInterestList.add(pIntRec);                          
                    }
                }
                
                if(prodInterestList.size()>0){
                    insert prodInterestList;
                }
            }     
            
        }
        catch(Exception e){
            system.debug('Error :: ' + e.getMessage());
            system.debug('At Line No :: ' + e.getLineNumber());
        }
    }
    
    private static void createOpportunity(set<Id> pAppIdSet){
        try{
            system.debug('pAppIdSet -- ' + pAppIdSet);
            List<Placement_Application__c> placementAppList = [SELECT Id, Program__r.Name, Name, Aptitude_Result__c, Aptitude_Marks__c, GD_Result__c, Program__c, Contact__c, Contact__r.Email, Contact__r.Internal_Student_Id__c, Contact__r.LMS_Student_Id__c 
                                                               FROM Placement_Application__c where Id IN: pAppIdSet AND Opportunity_Created__c = FALSE];
            system.debug('placementAppList -- ' + placementAppList);
            
            List<Program_Product__c> programProdList = [SELECT Id, Product__c FROM Program_Product__c WHERE Program__c =: placementAppList[0].Program__c];
            set<Id> prodIdSet = new set<Id>();
            for(Program_Product__c pProd : programProdList){
                prodIdSet.add(pProd.Product__c);
            }
            
            system.debug('prodIdSet  -- ' + prodIdSet);
            
            Id priceBookId = [SELECT Id FROM PriceBook2 WHERE Name = 'Standard Price Book'].Id;
            List<PriceBookEntry> pbeList = [SELECT Id, Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id IN: prodIdSet];
            Map<Id, PriceBookEntry> mapOfPbEntries = new Map<Id, PriceBookEntry>();
            Decimal totalPrice = 0;
            for(PriceBookEntry pbe : pbeList){
                mapOfPbEntries.put(pbe.Product2Id, pbe);
                totalPrice += pbe.UnitPrice;
            }
            
            List<Opportunity> oppListToBeInserted = new List<Opportunity>();
            Set<ID> conIds = new   Set<ID>();
            for(Placement_Application__c appRec : placementAppList){
                appRec.Opportunity_Created__c = TRUE;
                
                Opportunity opp = new Opportunity();
                opp.Name = appRec.Contact__r.LMS_Student_Id__c + '-' + placementAppList[0].Program__r.Name;
                opp.StageName = 'Closed-Won';
                opp.CloseDate = system.today();
                opp.Placement_Application__c = appRec.Id;
                opp.Pricebook2Id = priceBookId;
                opp.Contact__c = appRec.Contact__c;
                opp.Expected_Revenue__c = totalPrice;
                oppListToBeInserted.add(opp); 
                conIds.add(appRec.Contact__c);
            }
                        
            if(oppListToBeInserted.size()>0){
                update placementAppList;
                Database.insert(oppListToBeInserted,true);
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                
                for(Opportunity opp : oppListToBeInserted){
                    for(Id prodId : prodIdSet){
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Product2Id = prodId;
                        oli.OpportunityId = opp.Id;
                        oli.Quantity = 1;
                        oli.Discount = 100;
                        if(mapOfPbEntries.containsKey(prodId)){
                            oli.PricebookEntryId = mapOfPbEntries.get(prodId).Id; 
                            oli.UnitPrice = mapOfPbEntries.get(prodId).UnitPrice; 
                        }
                        oliList.add(oli);                          
                    }
                }
                if(oliList.size()>0){
                    insert oliList;
                }
                sendEmailToContactEmail(conIds);
            }     
            
        }
        catch(Exception e){
            system.debug('uploadPIResult ERROR -- ' + e.getMessage());
            system.debug('LINE NO -- ' + e.getLineNumber());
        }
    }

    private static void sendEmailToContactEmail(set<ID> conIds){
        
        List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
        System.debug('conIds---->'+conIds);
        List<String> conEmaiList = new List<String>();
        List<Contact> contactList = [SELECT ID, Name,LastName,FirstName, Email FROM Contact where Id IN:conIds]; 
        for(Contact conRec:contactList){
            if(conRec.Email !=null){
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(new string[] {conRec.Email} );
                mymail.setSenderDisplayName('Excelr');
                mymail.setSubject('Greetings for being an Ambassador');
                mymail.setSaveAsActivity(false);
                mymail.setPlainTextBody('Congratulations '+ conRec.LastName + ',' +'\n'+'\n' + 'I hope this email finds you well. On behalf of ExcelR, We want to extend our warmest congratulations to you for your exceptional achievement as an ambassador. ' +'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                semList.add(mymail);
            }
        }     
        Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(semList);
        /*if(emailResult[0].success)
            return 'success';
        else
            return 'error';*/
    }
    
    
}