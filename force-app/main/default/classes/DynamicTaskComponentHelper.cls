/*
* Author : Anjali Singh
*/

public without sharing class DynamicTaskComponentHelper {
    
    @AuraEnabled 
    Public Static Task getCurrentTaskRecord(String recordId){
        Task TaskRec = new Task();
        try{
            if(!String.isBlank(recordId)){
                TaskRec = [SELECT Id, Subject,Status, Component_Name__c, WhatId FROM Task WHERE Id =: recordId];
                if(TaskRec !=null){
                    return TaskRec;
                }
            }
        }
        catch(Exception e){
            System.debug('getCurrentTaskRecord -- Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled 
    Public Static Program__c getCurrentProgramRecord(String programId){
        Program__c programRec = new Program__c();
        try{
            if(!String.isBlank(programId)){
                programRec = [SELECT Id, Stage__c, Aptitude_Test_Date_Time__c, GD_Date_Time__c, Personal_Interview_Date_Time__c FROM Program__c WHERE Id =: programId];
                if(programRec !=null){
                    return programRec;
                }
            }
        }
        catch(Exception e){
            System.debug('getCurrentProgramRecord -- Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled 
    Public Static string updateProgramTask(Program__c prgrm, String taskId){
        system.debug('prgrm  -- ' + prgrm);
        system.debug('taskId  -- ' + taskId);
        string result = '';
        Program__c progRec = [SELECT Id, Name, Account__c, Aptitude_Test_Date_Time__c, Program_Start_Date_Time__c, GD_Date_Time__c, Personal_Interview_Date_Time__c, Stage__c FROM Program__c WHERE ID =:prgrm.Id];
        try{
            List<Program_Product__c> pProdList = [SELECT Id FROM Program_Product__c WHERE Program__c =: progRec.Id];
            if(pProdList.size() == 0){
                return 'no Prods';
            }
            else{
                if(!String.isBlank(taskId) && prgrm != null){
                    if(prgrm.Stage__c != 'Scheduled')
                        prgrm.Stage__c = 'Scheduled';
                    update prgrm;

                    Program__c progRecAfterUpdation = [SELECT Id, Name, Account__c, Aptitude_Test_Date_Time__c, Program_Start_Date_Time__c, GD_Date_Time__c, Personal_Interview_Date_Time__c, Stage__c FROM Program__c WHERE ID =:prgrm.Id];
                    
                    Task TaskRec = [SELECT Id, Subject,Status, Component_Name__c, WhatId FROM Task WHERE Id =: taskId];
                    TaskRec.Status = 'Completed';
                    update TaskRec;
                    result = 'success';
                    sendEmail(progRecAfterUpdation.Account__c,progRecAfterUpdation.Aptitude_Test_Date_Time__c,progRecAfterUpdation.Program_Start_Date_Time__c,progRecAfterUpdation.GD_Date_Time__c,progRecAfterUpdation.Personal_Interview_Date_Time__c);
                }
            }
            
        }
        catch(Exception e){
            System.debug('updateProgramTask -- Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            result = e.getMessage();
        }
        return result;
    }    
    
     public static void sendEmail(ID accountIds,DateTime aptDateTime,DateTime prgmDateTime,DateTime gdDateTime,DateTime persDateTime){
       
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

                mymail.setPlainTextBody('Hello ,'+conRec.LastName +'' +'\n'+'\n' + 'I trust this email finds you in good health. I am writing to discuss the possibility of conducting a placement drive at Your College for our graduating students.'+'\n'+' \n'+' Aptitudu Date Time :'+aptDateTime+'\n '+'Program Date Time :'+prgmDateTime+'\n '+'GD Date Time :'+gdDateTime+'\n '+'Personal Date Time :'+persDateTime+'\n '+ '\n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                    semList.add(mymail);
            }
        }     
             Messaging.sendEmail(semList);
    }
    
}