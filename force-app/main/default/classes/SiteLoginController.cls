/**
 * An apex page controller that exposes the site login functionality
 */
global without sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        try{
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('SiteLoginController', 'login', e , null);
       return null;
    }
}
    
   	global SiteLoginController () {}
}