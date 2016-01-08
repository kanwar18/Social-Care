// Jonathan Hersh - jhersh@salesforce.com - 8/5/2010
global with sharing class urlRewriter implements Site.UrlRewriter {
    global PageReference mapRequestUrl(PageReference myFriendlyUrl){
        String url = myFriendlyUrl.getUrl();
        
        if( url == null || url == '' || url == '/' )
            return new pageReference( urlHomeController.DEFAULT_URL );  
                        
        if( url.startsWith('/') )
            url = url.substring(1, url.length());
        
        if( url.length() > 100 )
            url = url.substring( 0, 100 );
            
       // Does this URL exist in the database?
       Short_URL__c[] links = [select id from Short_URL__c where short_url__c = :url limit 1];
       
       if( links.isEmpty() )
        return myFriendlyURL;
            
       PageReference p = Page.urlRedirect;
       p.setRedirect( true );
       p.getparameters().put('url',url);
           
       return p;
    }
    
    global List<PageReference> generateUrlFor(List<PageReference> 
            mySalesforceUrls){    
        return null;
    }

    public static testmethod void testRewriter() {
       Short_URL__c s = new Short_URL__c();
        s.Custom_URL__c = 'www.google.com' ;
        s.URL__c = 'www.google.com';
        insert s;
        
        string url = '/2ndIf';
        string url1 = '';
        string url2 = '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        urlRewriter ur = new urlRewriter();
        PageReference p = ur.mapRequestUrl( new pageReference( url ) );
        system.assertEquals( true, p.getRedirect() );
        system.assertEquals( url, p.getUrl() );
        PageReference q = ur.mapRequestUrl( new pageReference( url1 ) );
        PageReference r = ur.mapRequestUrl( new pageReference( url2 ) );
      
        //insert url  
        string url4 = 'www.google.com';
        PageReference t = ur.mapRequestUrl( new pageReference( url4 ) );
        system.assertEquals( null, ur.generateUrlFor( new PageReference[] {} ) );
    }
}