@RESTResource(urlMapping = '/webEngageWebhook/*')

global without sharing class WebEngageWebhookHandler{
    @HttpPost
    global static String engageWebhookListener(){
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
          //   Map<String,object> m1 = (Map<String,object>) JSON.deserializeUntyped(req);
            String body = req.requestBody.toString();
                 Map<String,object> m1 = (Map<String,object>) JSON.deserializeUntyped(body);
                             object m2 = m1.get('response');
                Map<String,object> m3 =  (Map<String,object>) m2;
                             object m4 =  m3.get('data');
                             //object  m3 = m2.get('data'); 
            System.debug('Body---' + body);
            return 'success';
        } catch (Exception e){
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