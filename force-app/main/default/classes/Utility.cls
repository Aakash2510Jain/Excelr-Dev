public without sharing class Utility{
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){

        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();

        for (Schema.PicklistEntry a : pick_list_values){

            lstPickvals.add(String.ValueOf(a.getLabel()).trim());
        }
        return lstPickvals;
    }

    public static List<String> getPicklistValuesWithNone(String ObjectApi_name, String Field_name){
        List<String> pickList = new List<String>{ '--None--' };
        pickList.addAll(getPicklistValues(objectApi_name, field_name));
        return pickList;
    }

    static Map<Id, UserRole> allRolesMap;
    public static ApprovalWrapper getUserQAMap(){
        Map<Id, Id> userRoleToQARoleMap = new Map<Id, Id>();

        allRolesMap = allRolesMap == null ? new Map<Id, UserRole>([SELECT Id, ParentRoleId, Name
                                                                   FROM UserRole]) : allRolesMap;
        for (UserRole ur : allRolesMap.values()){
            if (!ur.Name.containsIgnoreCase('QA') /*&& !ur.Name.containsIgnoreCase('CEO') && !ur.Name.containsIgnoreCase('Managing Director')*/){
                userRoleToQARoleMap.put(ur.Id, getQAIdRecursive(allRolesMap, ur));
            }
        }

        Map<Id, Id> usrRoleToQAIdMap = new Map<Id, Id>();
        if (!userRoleToQARoleMap.isEmpty()){
            List<User> userList = [SELECT Id, UserRoleId
                                   FROM User
                                   WHERE UserRoleId IN:userRoleToQARoleMap.values()];
            for (User usr : userList){
                if (!usrRoleToQAIdMap.containsKey(usr.UserRoleId))
                    usrRoleToQAIdMap.put(usr.UserRoleId, usr.Id);
            }
        }
        return new ApprovalWrapper(userRoleToQARoleMap, usrRoleToQAIdMap);
    }

    public static ApprovalWrapper getUserBHMap(){
        Map<Id, Id> userRoleToBHRoleMap = new Map<Id, Id>();

        allRolesMap = allRolesMap == null ? new Map<Id, UserRole>([SELECT Id, ParentRoleId, Name
                                                                   FROM UserRole]) : allRolesMap;
        for (UserRole ur : allRolesMap.values()){
            if (!ur.Name.containsIgnoreCase('Business Head')){
                userRoleToBHRoleMap.put(ur.Id, getBHIdRecursive(allRolesMap, ur));
            }
        }

        Map<Id, Id> usrRoleToBHIdMap = new Map<Id, Id>();
        if (!userRoleToBHRoleMap.isEmpty()){
            List<User> userList = [SELECT Id, UserRoleId
                                   FROM User
                                   WHERE UserRoleId IN:userRoleToBHRoleMap.values()];
            for (User usr : userList){
                if (!usrRoleToBHIdMap.containsKey(usr.UserRoleId))
                    usrRoleToBHIdMap.put(usr.UserRoleId, usr.Id);
            }
        }
        return new ApprovalWrapper(userRoleToBHRoleMap, usrRoleToBHIdMap);
    }

    Public static Id getQAIdRecursive(Map<Id, UserRole> userRoleMap, UserRole currentRole){
        if (currentRole.ParentRoleId != null && userRoleMap.get(currentRole.ParentRoleId).Name != null && userRoleMap.get(currentRole.ParentRoleId).Name.containsIgnoreCase('QA')){
            return userRoleMap.get(currentRole.ParentRoleId).Id;
        } else if (currentRole.ParentRoleId != null){
            return getQAIdRecursive(userRoleMap, userRoleMap.get(currentRole.ParentRoleId));
        } else{
            return null; //TOP Role - CEO.
        }
    }

    Public static Id getBHIdRecursive(Map<Id, UserRole> userRoleMap, UserRole currentRole){
        if (currentRole.ParentRoleId != null && userRoleMap.get(currentRole.ParentRoleId).Name != null && userRoleMap.get(currentRole.ParentRoleId).Name.containsIgnoreCase('Business Head')){
            return userRoleMap.get(currentRole.ParentRoleId).Id;
        } else if (currentRole.ParentRoleId != null){
            return getBHIdRecursive(userRoleMap, userRoleMap.get(currentRole.ParentRoleId));
        } else{
            return null; //TOP Role - CEO.
        }
    }

    public class ApprovalWrapper{
        public Map<Id, Id> smToManagerMap;
        public Map<Id, Id> managerRoleToUserIdMap;
        public ApprovalWrapper(Map<Id, Id> smToManagerMap, Map<Id, Id> managerRoleToUserIdMap){
            this.smToManagerMap = smToManagerMap;
            this.managerRoleToUserIdMap = managerRoleToUserIdMap;
        }

    }

    Public Static void CreateInvoice(String recordId){

        Invoice__c InvoiceRec = new Invoice__c();
        InvoiceRec.Opportunity__c = recordId;
        InvoiceRec.Status__c = 'Initiated';

        insert InvoiceRec;
    }

    public static void UTMLinkParams(Lead leadRec){
        try{
            if (leadRec.Enter_UTM_Link__c != null){
                string urlValue = string.valueOf(leadRec.Enter_UTM_Link__c);
                System.PageReference pageReference = new System.PageReference(urlValue);
                Map<String, String> parameters = pageReference.getParameters();
                system.debug('utm_source ::' + parameters.get('utm_channel'));
                leadRec.UTM_Source__c = parameters.get('utm_source');
                leadRec.UTM_Medium__c = parameters.get('utm_medium');
                leadRec.UTM_Term__c = parameters.get('utm_term');
                leadRec.UTM_Content__c = parameters.get('utm_content');
                leadRec.UTM_Device__c = parameters.get('utm_device');
                leadRec.UTM_Campaign__c = parameters.get('utm_campaign');
                leadRec.UTM_AdGroup__c = parameters.get('utm_adgroup');
                leadRec.UTM_Location__c = parameters.get('utm_location');
                leadRec.UTM_Channel__c = parameters.get('utm_channel');
                leadRec.UTM_Type__c = parameters.get('utm_type');
                leadRec.UTM_Variety__c = parameters.get('utm_variety');
                leadRec.UTM_Experiment__c = parameters.get('utm_experiment');

                leadRec.GCLID__c = parameters.get('gclid');

               // leadRec.Source__c = parameters.get('source');
                //leadRec.Medium__c = parameters.get('medium');
              //  leadRec.Campaign__c = parameters.get('campaign');
                leadRec.AdGroup__c = parameters.get('adgroup');
                leadRec.Keyword__c = parameters.get('keyword');
                leadRec.Match_Type__c = parameters.get('matchtype');
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('Utility', 'UTMLinkParams', e);
        }
    }

    public static void convertLeadAfterPayment(string leadId, Map<String, Object> paymentResponse){
        try{
            Map<String, string> priceBookIdByProductId = new Map<String, String>();
            List<Invoice__c> invoiceListAttachedToLead = new List<Invoice__c>();
            List<Invoice__c> invoiceListToUpdate = new List<Invoice__c>();
            List<Application__c> applicationsListAttachedToLead = new List<Application__C>();
            List<Application__c> applicationsListToUpdate = new List<Application__C>();

            if (paymentResponse.get('captured') == true){
                //covert lead
                LeadStatus convertStatus = [SELECT Id, MasterLabel
                                            FROM LeadStatus
                                            WHERE IsConverted = true
                                            LIMIT 1];
                Database.LeadConvert convert = new Database.LeadConvert();
                convert.setConvertedStatus(convertStatus.MasterLabel);
                convert.setLeadId(leadId);
                Database.LeadConvertResult convertedLead = Database.convertLead(convert);
                if (convertedLead.isSuccess()){
                    //invoice tag
                    //opp item tag
                    //opportunity to be updated
                    Lead convertedLeadRec = [Select Id, Payment_initiated_Date_Time__c, course__c, Quantity__c, Product__c, Total_Amount__c
                                             From Lead
                                             Where Id = :convertedLead.getLeadId()];
                    Account covertedAccRec = [Select Id, (Select Id
                                                          From Opportunities)
                                              From Account 
                                              where id = :convertedLead.getAccountId()];
                    //Opportunity opportunityRec = [Select Id From Opportunity where id =: ]
                    invoiceListAttachedToLead = [Select Id, Opportunity__c, Status__c
                                                 from Invoice__c
                                                 Where LeadInvoice__c = :convertedLeadRec.Id
                                                 order by createdDate Desc];
                    applicationsListAttachedToLead = [Select Id, Account__c
                                                      From Application__c
                                                      Where Lead__c = :convertedLeadRec.Id];
                    List<PricebookEntry> priceBookEntryList = [Select Id, Product2Id
                                                               From PricebookEntry
                                                               where Product2Id = :convertedLeadRec.Product__c];
                    for (PricebookEntry pbe : priceBookEntryList){
                        priceBookIdByProductId.put(pbe.Product2Id, pbe.Id);
                    }

                    Opportunity oppRec = new Opportunity();
                    oppRec.Id = covertedAccRec.Opportunities[0].Id;
                    oppRec.StageName = 'Closed Won';
                    update oppRec;

                    OpportunityLineItem oppProdRec = new OpportunityLineItem();
                    //oppProdRec.Discount = convertedLeadRec.Discount__c;
                    oppProdRec.OpportunityId = covertedAccRec.Opportunities[0].Id;
                    oppProdRec.Product2Id = convertedLeadRec.Product__c;
                    oppProdRec.Quantity = convertedLeadRec.Quantity__c;
                    oppProdRec.TotalPrice = convertedLeadRec.Total_Amount__c;
                    oppProdRec.PricebookEntryId = priceBookIdByProductId.get(convertedLeadRec.Product__c);
                    insert oppProdRec;
                    integer i = 0;
                    if (!invoiceListAttachedToLead.isEmpty()){
                        for (Invoice__c invoiceRec : invoiceListAttachedToLead){
                            Invoice__c invoiceRecToUpdate = new Invoice__c();
                            invoiceRecToUpdate.Id = invoiceRec.Id;
                            if (i == 0){
                                invoiceRecToUpdate.Opportunity__c = covertedAccRec.Opportunities[0].Id;
                                invoiceRecToUpdate.Status__c = 'Realized';
                                invoiceListToUpdate.add(invoiceRecToUpdate);
                            } else{
                                invoiceRecToUpdate.Opportunity__c = covertedAccRec.Opportunities[0].Id;
                                invoiceListToUpdate.add(invoiceRecToUpdate);
                            }
                            i++;
                        }
                        if (!invoiceListToUpdate.isEmpty()){
                            update invoiceListToUpdate;
                        }
                    }

                    if (!applicationsListAttachedToLead.isEmpty()){
                        for (Application__c appRec : applicationsListAttachedToLead){
                            Application__c appRecToUpdate = new Application__c();
                            appRecToUpdate.Id = appRec.Id;
                            if (convertedLeadRec.Course__c != null && appRec.Course__c != null){
                                if (convertedLeadRec.Course__c == appRec.Course__c){
                                    appRecToUpdate.Status__c = 'Closed Won';
                                }
                            }
                            appRecToUpdate.Account__c = convertedLead.getAccountId();
                            applicationsListToUpdate.add(appRecToUpdate);
                        }
                        if (!applicationsListToUpdate.isEmpty()){
                            update applicationsListToUpdate;
                        }
                    }


                }
            } else{
                //update status as failed


                List<Invoice__c> invoiceList = [Select Id, Status__c, Opportunity__c
                                                From Invoice__c
                                                where LeadInvoice__c = :leadId
                                                order by CreatedDate DESC
                                                limit 1];
                invoiceList[0].Status__c = 'Not Realized';
                update invoiceList;

            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }

    public static string createApplicationInstance(string leadId, string courseName){
        string applicationId = '';
        Application__c appRec = new Application__c();
        appRec.Applied_Date_Time__c = system.now();
        appRec.Course__c = courseName;
        if (leadId.startsWith('00Q'))
            appRec.Lead__c = leadid;
        if (leadId.startsWith('001'))
            appRec.Account__c = leadid;
        applicationId = API_CreateAccount.insertApplication(appRec);
        return applicationId;
    }
    
    

}