public without sharing class ConvertLeadManuallyHelper {
    @auraEnabled
    public static void convertLead(string leadId){
        try{
        system.debug('leadId-->'+leadId);
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('ConvertLeadManuallyHelper', 'convertLead', e , null);
       
    }

}
}