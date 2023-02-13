@RESTResource(urlMapping = '/webEngageWebhook/*')

global without sharing class WebEngageWebhookHandler{
    public static string name;
    public static string email;
    public static string phone;
    public static String description;
    public static String course;
    public static string requestString;
    @HttpPost
    global static String engageWebhookListener(){
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String body = req.requestBody.toString();
            requestString = body;
            system.debug('body-->'+body);
            Map<String,object> bodyMap = (Map<String,object>) JSON.deserializeUntyped(body);
            system.debug('bodymap ===> ' + bodyMap);
            object m2 = bodyMap.get('response');
            system.debug('m2 ===> ' + m2);
            Map<String,object>  m3 =  (Map<String,object>) m2;
            system.debug('m3 ===> ' + m3);
            Map<String,object> dataMap = ( Map<String,object>) m3.get('data');
            system.debug('dataMap ===> ' + dataMap);
            List<Object> listQuestionResponse = (List<Object>)  dataMap.get('questionResponses');
            Map<String,object> activityObject = (Map<String,object>)dataMap.get('activity');
            //Map<String, object) activityMap = ()activityObject
            
            system.debug('listQuestionResponse ===> ' + listQuestionResponse);
            integer i=0;
            for(Object o:listQuestionResponse)
            {
                i++;
                System.debug('i Value'+i);
                Map<string,Object> m = (Map<string,Object>) o;
                Map<string,Object> l = (Map<string,Object>) m.get('value');
                system.debug('l ====> ' + l);
                if(i<listQuestionResponse.size()){
                    
                    Map<string,Object> l1 = (Map<string,Object>) l.get('values');
                    system.debug('l1 ====> ' + l1);
                    if(l1.containsKey('Name*'))
                    {
                        name = (string) l1.get('Name*');
                    }
                    if(l1.containsKey('E-mail*'))
                    {
                        email = (string) l1.get('E-mail*');
                    }
                    if(l1.containsKey('Mobile Number*'))
                    {
                        phone =(string) l1.get('Mobile Number*');
                    }
                    if(l1.containsKey('Mobile Number*'))
                    {
                        phone =(string) l1.get('Mobile Number*');
                    }
                    if(l1.containsKey('Course name'))
                    {
                        course =(string) l1.get('Course name');
                    }
                    
                }    
                else{
                    List<object> valueList = (List<object>) l.get('values');
                    description =string.valueOf(valueList);
                    System.debug('ValueList'+valueList);
                }
            }
            System.debug('Name :'+name);
            System.debug('email'+email);
            System.debug('phone'+phone);
            System.debug('Body---' + body);
            System.debug('course---' + course);
            List<lead> leadList = new List<lead>();
            Lead leadRec = new Lead();
            leadRec.LastName  = name;
            leadRec.Phone = phone;
            leadRec.Email = email;
            leadRec.Course__c = course != null?course:'NA';
            
            system.debug('activity ===> ' + activityObject.get('city'));
            
            leadRec.Enter_UTM_Link__c = (string)activityObject.get('pageUrl');
            leadRec.City__c = (string)activityObject.get('city');
            leadRec.Country__c = (string)activityObject.get('country');
           // leadRec.Platform__c = (string)activityObject.get('platform');
            //leadRec.Activity_On__c	= (DateTime)JSON.deserialize('"' + String.valueOf(activityObject.get('activityOn')) + '"', DateTime.class);
            
            leadRec.Description =description ;
            leadList.add(leadRec);
            system.debug('leadlist ====> ' + leadlist);
            insert leadList;
            return 'success';
        } catch (Exception e){
            system.debug('error due to ' + e.getMessage());
            system.debug('at line number ' + e.getLineNumber());
           HandleBusinessException.captureError('WebEngageWebhookHandler','engageWebhookListener', e, requestString);
            return 'Error - ' + e.getMessage();
        }
    }
}

/*
{
"response": {
"data": {
"surveyId": "7djkd2l",
"title": "ExcelR.in &#124; Data Analyst &#124; Tier 1 &#124; Mobile &#124; Mumbai",
"totalQuestions": 4,
"licenseCode": "~15ba20116",
"questionResponses": [
{
"questionId": "~1ad8i5b",
"questionText": "",
"order": 1,
"value": {
"@class": "map",
"values": {
"Name*": "Ranjit Rane"
}
}
},
{
"questionId": "~17kd2n7",
"questionText": "",
"order": 2,
"value": {
"@class": "map",
"values": {
"E-mail*": "rane.ranjit@gmail.com"
}
}
},
{
"questionId": "~14rhhb3",
"questionText": "",
"order": 3,
"value": {
"@class": "map",
"values": {
"Mobile Number*": "9769148922"
}
}
},
{
"questionId": "143k7nq",
"questionText": "",
"order": 4,
"value": {
"@class": "list",
"values": [
"I hereby agree to the TnC & Privacy Policy of ExcelR Solutions"
]
}
}
],
"id": "3qn9flk",
"activity": {
"pageUrl": "https://excelr.in/data_analyst_course_mumbai/?utm_source=google&utm_medium=cpc&utm_term=data%20analytics&utm_content=553986113743&utm_device=m&utm_campaign=Search-DA_BA-MumbaiAndThane&utm_adgroup=Search-DataAnalytics-Generic-Phrase&utm_location=Mumbai&gclid=CjwKCAiA76-dBhByEiwAA0_s9XkjEDYSc0ZzX80zO8-lOBpevtGaUqf96dCxkumTrafwbbU7Fs-w-RoCm-AQAvD_BwE",
"ip": "152.58.43.70",
"city": "",
"country": "India",
"browser": "Chrome",
"browserVersion": "103",
"platform": "Android",
"activityOn": "2022-12-29T06:36:22+0000"
}
}
}
}
*/