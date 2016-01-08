public with sharing class Url_Shortener_Ctr_v2{
    
    public string access_token {get;set;}

    public string username {get;set;}
    public string password {get;set;}

    public string inputUrl {get;set;}
    public string shortUrl {get;set;}

    public string service {get;set;}


    public Url_Shortener_Ctr_v2(){
        inputUrl = 'http://';
        bitly_login__c bit = bitly_login__c.getValues('bitly_login');
        system.debug(bit);
        if(bit == null){
            service = null;
        }
        else{
            if(bit.active__c){
                username = bit.username__c;
                password = bit.password__c;
                if( String.isBlank(username) || String.isBlank(password) ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Check custom setting for username & password'));
                    
                }
                else{
                    service = 'Bitly';
                    if(!Test.isRunningTest()){
                        getLogin();
                    }
                }
            }
            
        }

    }

    public pageReference setService(){

        return null;
    }


    public List<SelectOption> getServices() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('',''));
        options.add(new SelectOption('Bitly','Bitly'));
        //options.add(new SelectOption('TinyUrl','TinyUrl'));
        return options;
    }


    public pageReference getLogin(){

        if( String.isBlank(username) || String.isBlank(password) ){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter your username & password'));
           
            return null;
        }

        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api-ssl.bitly.com/oauth/access_token');
        req.setMethod('POST');
          
        Blob headerValue = Blob.valueOf(username + ':' + password);
        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        req.setHeader('Authorization', authorizationHeader);

        HttpResponse res = h.send(req);
               
        System.debug(res.getHeaderKeys());
        if(res.getStatusCode() == 200){
            String body = res.getBody();
            
            if(body.contains('status_txt')){
                if(body.contains('INVALID_LOGIN')){
                    access_token = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid login, please try again'));
                    return null;
                }else{
                    access_token = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not sign in, please try again'));
                    return null;
                }
            }else{
            
                access_token = body;
            }
        }else{
            access_token = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not sign in, please try again'));
            
            return null;
        }
        
        return null;

    }
    
    
    public pageReference getBitlyShortUrl(){

        if(!inputUrl.startsWithIgnoreCase('http://') && !inputUrl.startsWithIgnoreCase('https://')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid url'));
            return null;
        }
        
        if(inputUrl.equalsIgnoreCase('http://') || inputUrl.equalsIgnoreCase('https://')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid url'));
            return null;
        }

        if(access_token.equalsIgnoreCase('') || access_token == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please sign in again'));
            return null;
        }

        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api-ssl.bitly.com/v3/shorten?access_token='+access_token+'&longUrl=' + inputUrl);

        req.setMethod('GET');
        
        HttpResponse res = h.send(req);
        if (  200 == res.getStatusCode()){        
            Map<String, Object> source = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (source.containsKey('data')){
                Object d= source.get('data');
                String data = String.valueOf(d).replace('{','').replace('}','');
                for(String lpart : data.split(',')){ 
                    lpart = lpart.trim();
                    if (lpart.startsWith('url=')){
                        shortUrl = lpart.replace('url=','');
                    }
                } 
            }
        }
            
        if(String.isEmpty(shortUrl)){                 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This service is unavailable, please try a different one'));
        }
        return null;
    }


    public pageReference getTinyShortUrl(){

        if(!inputUrl.startsWithIgnoreCase('http://') && !inputUrl.startsWithIgnoreCase('https://')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid url'));
            return null;
        }

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://tinyurl.com/api-create.php?url=' + inputUrl);
        req.setMethod('GET');
        // Send the request, and return a response
        HttpResponse res = h.send(req);
            
        shortUrl = res.getBody();
        
        if(String.isEmpty(shortUrl)){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This service is not working, please try another'));
        }
        
        return null;
    }


    public pageReference chooseService(){
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(false);
        shortUrl = '';
        inputUrl = 'http://';
        service = null;
        access_token = null;
        return pageRef;
    }

    
    
    public pageReference clear(){
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(false);
        shortUrl = '';
        inputUrl = 'http://';
        return pageRef;
    }


}