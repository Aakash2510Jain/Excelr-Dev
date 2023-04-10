public without sharing class bankDetaklsLwcContrroler{
    @auraenabled
    public static void createBankDetails(String AcNum, String Bname, String ifseCode, String CandidateEmail, String Phone){
        try{
            List<Account> accList = new List<Account>();

            accList = [Select Id
                       From Account
                       where Email__c = :CandidateEmail
                       limit 1];

            if (!accList.isEmpty()){
                system.debug('YES');
                Bank_Details__c bankRec = new Bank_Details__c();
                bankRec.Account_No__c = AcNum;
                bankRec.Bank_Name__c = Bname;
                bankRec.IFSC_Code__c = ifseCode;
                bankRec.Candidate_Email__c = CandidateEmail;
                bankRec.Candidate_Phone__c = Phone;
                bankRec.Account__c = accList[0].Id;
                system.debug('bankRec:::' + bankRec);
                insert bankRec;
            } else{
                system.debug('NO');
                Bank_Details__c bankRec = new Bank_Details__c();
                bankRec.Account_No__c = AcNum;
                bankRec.Bank_Name__c = Bname;
                bankRec.IFSC_Code__c = ifseCode;
                bankRec.Candidate_Email__c = CandidateEmail;
                bankRec.Candidate_Phone__c = Phone;
                system.debug('bankRec:::' + bankRec);
                insert bankRec;

            }

        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('bankDetaklsLwcContrroler', 'createBankDetails', e, null);

        }
    }

    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId){
        string CvID;
        try {
            System.debug('base64 ====> ' + base64);
        System.debug('filename ====> ' + filename);
        System.debug('recordId ====> ' + recordId);
        List<Invoice__c> invoicerecList = [SELECT ID, OwnerId From Invoice__c Where Id =: recordId ];

        ContentVersion cv = createContentVersion(base64, filename, invoicerecList[0].OwnerId, recordId);
        System.debug('cv ====> ' + cv);

        ContentDistribution ContDis = CreateContentDistribution(cv.Id, filename, invoicerecList[0].Id);

        ContentDocumentLink cdl = createContentLink(cv.Id, invoicerecList[0].Id);
        System.debug('cdl ====> ' + cdl);
        CvID = cdl.Id;

        if (cv == null || cdl == null){
            return null;
        }
            
        } catch (Exception e) {
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            
        }
        
        return CvID;
    }

    @AuraEnabled
    public static ContentVersion createContentVersion(String base64, String filename, string recordownerId ,string recordId){
        System.debug('recordId ====> ' + recordownerId);
        System.debug('filename ====> ' + filename);
        

        base64 = EncodingUtil.urlDecode(base64, 'UTF-8');
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        //cv.ContentLocation = 'S';
        cv.SharingPrivacy = 'N';
        cv.Title = filename;
        cv.PathOnClient = '/' + filename;
        cv.isMajorVersion = false;
        cv.OwnerId = recordownerId;

        cv.FirstPublishLocationId = recordId;

        System.debug('cv =====> ' + cv);
        try{
            insert cv;
            return cv;
        } catch (DMLException e){
            
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static ContentDistribution CreateContentDistribution(String CVId, String filename, String recId){
        try{
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = CVId;
            cdl.Name = fileName;
            cdl.RelatedRecordId = recId;
            cdl.PreferencesAllowViewInBrowser = true;
            cdl.PreferencesLinkLatestVersion = true;
            cdl.PreferencesAllowOriginalDownload = true;
            insert cdl;
            return cdl;

        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ContentDocumentLink createContentLink(String contentVersionId, String recId){
        if (contentVersionId == null || recId == null){
            return null;
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId
                                 FROM ContentVersion
                                 WHERE Id = :contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        System.debug('cdl =====> ' + cdl);
        try{
            insert cdl;
            return cdl;
        } catch (DMLException e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static Id SaveFile(Id parentId, String fileName, String base64Data, String contentType, String foldname){

        System.debug('parentId ====>' + parentId);
        System.debug('fileName ====>' + fileName);
        System.debug('base64Data ====>' + base64Data);
        System.debug('contentType ====>' + contentType);
        System.debug('foldname ====>' + foldname);

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        // list<Folder__c> f = [Select id, Name, OwnerId
        //                      From Folder__c
        //                      where Name = 'Resume' AND Lead__c = :parentId
        //                      limit 1];
        // system.debug('f::' + f);
        // list<Folder__c> folderRec = [Select id, Name, OwnerId
        //                              From Folder__c
        //                              where Name = :foldname AND Lead__c = :parentId
        //                              limit 1];
        // system.debug('folderRec::' + folderRec);


        // string fileId1 = f.id;


        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName;//File name with extention
        //cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.

        //cVersion.OwnerId = folderRec[0].OwnerId;
        cVersion.Title = fileName;//Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
        cVersion.isMajorVersion = false;
        Insert cVersion;

        ContentDistribution cdl = new ContentDistribution();
        cdl.ContentVersionId = cVersion.Id;
        cdl.Name = fileName;

        //cdl.RelatedRecordId = folderRec[0].id;
        cdl.PreferencesAllowViewInBrowser = true;
        cdl.PreferencesLinkLatestVersion = true;
        cdl.PreferencesAllowOriginalDownload = true;
        insert cdl;

        System.debug('cdl ======> ' + cdl);

        System.debug('cVersion =====> ' + cVersion);
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId
                          FROM ContentVersion
                          WHERE Id = :cVersion.Id].ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        //cDocLink.LinkedEntityId = folderRec[0].id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        //cDocLink.Visibility = 'SharedUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        System.debug('cDocLink ======> ' + cDocLink);

        // list<Folder__c> f1 = [Select id,Name From Folder__c where Name = 'Resume' AND id='00Q1e000002UfqeEAC' ];

        return cVersion.Id;
    }

}