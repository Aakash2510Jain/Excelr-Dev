public without sharing class HTTPUtility 
{
    public static HttpResponse sendRequest(String endPoint, String token, String body, String methodType) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod(methodType);
            request.setBody(body);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token);

            HttpResponse response = http.send(request);
            return response;
        } catch (Exception e) {
            System.debug('ERROR :: ' + e.getMessage() + ' AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('HTTPUtility', 'sendRequest', e, null);
            return null;
        }
    }

    static final String NO_RESPONSE = 'NO_RESPONSE';
    static final String HTTP_ERROR = 'ERROR WHILE MAKING REQUEST';
    static Excelr_Configuration__c excelrObj;

    static HttpUtility httpUtilityInstance;

    private HttpUtility() {
    }

    public static HttpUtility getInstance() {
        if (httpUtilityInstance == null) {
            httpUtilityInstance = new HttpUtility();
            excelrObj = Excelr_Configuration__c.getInstance();
        }
        return httpUtilityInstance;
    }

    public HttpResponse httpReqHelper(Map<String, String> headerMap, String method, String jsonBody, String endPoint, List<Id> insertedRecordIds) {
        utillabs__Integration_Log__c logger = new utillabs__Integration_Log__c();
        logger.utillabs__HTTP_Method__c = method;
        logger.utillabs__Integration_Type__c = 'CALLOUT';
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endPoint);
        httpRequest.setMethod(method);
        httpRequest.setBody(jsonBody);

        if (!headerMap.isEmpty()) {
            for (String key : headerMap.keySet()) {
                httpRequest.setHeader(key, headerMap.get(key));
            }
        }

        try {
            Http http = new Http();
            logger.utillabs__Start_Date_And_Time__c = System.now();
            HttpResponse response = http.send(httpRequest);
            logger.utillabs__End_Date_And_Time__c = System.now();

            if (insertedRecordIds != null && !insertedRecordIds.isEmpty()) {
                logger.Reference_Id__c = String.join(insertedRecordIds, ',');
            }

            if (excelrObj != null && excelrObj.Enable_Callouts_Logger__c) {
                createLog(logger, httpRequest, response, null);
            }

            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                return response;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('--- e-message ' + e.getMessage());
            System.debug('--- e-line-no ' + e.getLineNumber());
            HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e, null);
            return null;
        }
    }

    private void createLog(utillabs__Integration_Log__c logger, HttpRequest httpReq, HttpResponse httpRes, List<Id> insertedRecordIds) {
        if (httpReq != null) {
            logger.utillabs__Request_Body__c = httpReq.getBody();
            logger.utillabs__EndPoint__c = httpReq.getEndPoint();
        }
        if (httpRes != null) {
            logger.utillabs__Response_Body__c = httpRes.getBody();
            logger.utillabs__Response_Status_Code__c = httpRes.getStatusCode();
        }
        if (insertedRecordIds != null && !insertedRecordIds.isEmpty()) {
            logger.Reference_Id__c = String.join(insertedRecordIds, ',');
        }
        insert logger;
    }

    public void createServiceLogger(String reqBody, String resBody, String endPoint, String method, Integer statusCode, DateTime startDatetime, DateTime endDateTime, List<Id> insertedRecordIds) {
        try {
            if (excelrObj != null && excelrObj.Enable_Service_Logger__c) {
                utillabs__Integration_Log__c logger = new utillabs__Integration_Log__c();
                logger.utillabs__HTTP_Method__c = method;
                logger.utillabs__Integration_Type__c = 'SERVICE';
                logger.utillabs__Request_Body__c = reqBody;
                logger.utillabs__Response_Body__c = resBody;
                logger.utillabs__EndPoint__c = endPoint;
                logger.utillabs__Response_Status_Code__c = statusCode;
                logger.utillabs__Start_Date_And_Time__c = startDatetime;
                logger.utillabs__End_Date_And_Time__c = endDateTime;
                if (insertedRecordIds != null && !insertedRecordIds.isEmpty()) {
                    logger.Reference_Id__c = String.join(insertedRecordIds, ',');
                }

                insert logger;
                System.debug('logger.Id -- ' + logger.Id);
            }
        } catch (DMLException e) {
            System.debug('--- e-message ' + e.getMessage());
            System.debug('--- e-line-no ' + e.getLineNumber());
            HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e, null);
        }
    }
}