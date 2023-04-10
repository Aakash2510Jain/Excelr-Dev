public without sharing class Webhookwrapper {
    
    public String employeeName {get;set;} 
	public String employeeNumber {get;set;} 
	public String countryCode {get;set;} 
	public List<Logs> Logs {get;set;}

    public class Logs {
		public String id {get;set;} 
		public String name {get;set;} 
		public String countryCode {get;set;} 
		public String number_Z {get;set;} // in json: number
		public String duration {get;set;} 
		public String CalTtime {get;set;} 
		public String callType {get;set;} 
		public String note {get;set;} 
		public String createdDate {get;set;} 
		public String codifiedDate {get;set;} 
    }

    public static Webhookwrapper parse(String json) {
		try{
		return (Webhookwrapper) System.JSON.deserialize(json, Webhookwrapper.class);
	} catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('Webhookwrapper', 'parse', e , null);
       return null;
    }
}
}