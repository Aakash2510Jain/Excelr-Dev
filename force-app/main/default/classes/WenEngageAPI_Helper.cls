public class WenEngageAPI_Helper {
    public users users { get; set; }
    
    public class users {
        public String firstName { get; set; }
        public String email { get; set; }
        public String userId { get; set; }
        public String phone { get; set; }
        public Attributes attributes { get; set; }
        
    }
    public class Attributes {
        public String Course { get; set; }
    }
    
}
/*
    // Create an instance of the JSONResponse class and populate its properties
    WenEngageAPI_Helper response = new WenEngageAPI_Helper();
    response.firstName = 'Aakash Jain Testing12';
    response.email = 'aakash.jain12@mailinator.com';
    response.userId = '932833243228838320912';
    response.phone = '932833243228838320912';
    response.attributes = new WenEngageAPI_Helper.Attributes();
    response.attributes.Course = 'Data Science PG';
    
    // Serialize the response object into JSON
    String jsonResponse = JSON.serialize(response);
    
    // Print or return the JSON response
    System.debug(jsonResponse);
    */
        /*
        WenEngageAPI_Helper reuestBody = new WenEngageAPI_Helper();
        reuestBody.firstName = leadList[0].LastName;
        reuestBody.email = leadList[0].Email;
        reuestBody.userId = leadList[0].Phone;
        reuestBody.phone = leadList[0].Phone;
        reuestBody.attributes = new WenEngageAPI_Helper.Attributes();
        reuestBody.attributes.Course = leadList[0].Course__c;
        
        String jsonrequesBody = JSON.serialize(reuestBody);
        */