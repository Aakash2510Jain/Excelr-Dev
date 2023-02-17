public without sharing class CustomLookupLwcController{
    @AuraEnabled(cacheable = true)
    public static list<sObject> fetchLookupData(string searchKey, string sObjectApiName){
        system.debug('----fetchLookupData----');
        system.debug('sObjectApiName--->' + sObjectApiName);
        List<sObject> returnList = new List<sObject>();
        try{
            string userName = 'execsponsor.d4mfunnxgo49.tomlybmt6vbv.qzkw7kma3ryp@example.com.dev';
            string sQuery = '';
            string sWildCardText = '%' + searchKey + '%';
            if (sObjectApiName == 'user'){
                sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText AND userType = \'Standard\' and Username !=: userName and isActive = true order by createdDate DESC LIMIT 8';
            } else{
                sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 8';
            }

            for (sObject obj : database.query(sQuery)){
                returnList.add(obj);
            }
            return returnList;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CustomLookupLwcController', 'fetchLookupData', e, null);
            return null;
        }
    }

    // Method to fetch lookup default value
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId, string sObjectApiName){
        system.debug('----fetchDefaultRecord----');
        system.debug('sObjectApiName--->' + sObjectApiName);
        try{
            string sRecId = recordId;
            string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
            for (sObject obj : database.query(sQuery)){
                return obj;
            }
            return null;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CustomLookupLwcController', 'fetchDefaultRecord', e, null);
            return null;
        }
    }

}