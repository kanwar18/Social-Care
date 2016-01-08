//A twitter handle class sends DM to the Twitter
public class SocialMediaTwitterRest {
     
     public OAuthWrapper oauthWrap = null;
     public static final String TWITTER_ENDPOINT_URL = Label.TWITTER_DM_ENDPOINT;

     //No-Args Cons
     public SocialMediaTwitterRest() {
        oauthWrap = new OAuthWrapper();
     }
     
     //Method used to invoke the twitter api
     public String invokeTwitterRequest() {
        
        // End User(Screen Name) and Message
        
        /*String endUserScreenName = 'mvijaysfdc';
        String messageUpdate = 'Whats up2';*/
        
        String endUserScreenName = oauthWrap.dmReceiver;
        String messageUpdate = oauthWrap.directMessage;
        
        // Twitter End Point URL 
        String endPointUrl =  TWITTER_ENDPOINT_URL;  
        
        // Login User Details
        /*String consumerKey = 'QPJXxYRWrT4SAZEkdOVWA';
        String consumerSecret = 'rrEFTp8Hp02wCkYrYhTTaWWgXtzGmhFBsxyjUThmsL0';
        String accessToken = '914061876-aJz4vKxcCG6sQbxJjc2WRSvTH9XuQKZ9SdduSM6v';
        String accessSecret = 'MznvfYYKz2wLAP2yFzNkW6XuVegSVzN8NvBx9Sz4Y';*/
        
        String consumerKey = oauthWrap.consumerKey;
        String consumerSecret = oauthWrap.consumerSecret;
        String accessToken = oauthWrap.accessToken;
        String accessSecret = oauthWrap.accessSecret;
        
        // Signature = base64(hmac-sha1(signature_base_string, signature_key))
        String signature_base_string = '';
        String parameter_string = '';
        String signature_string = '';
        
        // Consumer_secret & token_secret 
        String signature_key = consumerSecret + '&' + accessSecret;
        
        // Set Auth Header
        String nonceValue = datetime.now().getTime() + 'Sales';
        Integer timeStamp = Integer.valueOf(datetime.now().getTime()/1000);
        
        String authHeader;
        
        authHeader = 'OAuth ' + 'realm="", oauth_nonce="' + nonceValue +
                     '", oauth_timestamp="' + timeStamp + '", oauth_consumer_key="' + consumerKey + 
                     '", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_token="' + accessToken + '", oauth_signature="';
                     
        // Set Signature Base String (HTTP_METHOD "&" urlencode(normalized_url) "&" urlencode(parameters_string))
        signature_base_string = 'POST' + '&' + EncodingUtil.urlEncode(endPointUrl, 'UTF-8');
        
        // Set Paramter String
        parameter_string = 'oauth_consumer_key=' + consumerKey; 
        parameter_string += '&' + 'oauth_nonce=' + nonceValue;
        parameter_string += '&' + 'oauth_signature_method=HMAC-SHA1';
        parameter_string += '&' + 'oauth_timestamp=' + timeStamp;
        parameter_string += '&' + 'oauth_token=' + accessToken;
        parameter_string += '&' + 'oauth_version=1.0';
        
        // Direct Messages
        parameter_string += '&' + 'screen_name=' + endUserScreenName;
        parameter_string += '&' + 'text=' + EncodingUtil.urlEncode(messageUpdate, 'UTF-8').replace('+', '%20');
          
        signature_base_string += '&' + EncodingUtil.urlEncode(parameter_string, 'UTF-8');
        Blob mac = Crypto.generateMac('hmacSHA1',  Blob.valueOf(signature_base_string), Blob.valueOf(signature_key));
        signature_string = EncodingUtil.base64Encode(mac);
        
        // Set Auth Header
        authHeader += EncodingUtil.urlEncode(signature_string, 'UTF-8').replace('+', '%20') + '"';
        
        // Create Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointUrl);
        req.setMethod('POST');
        req.setHeader('Authorization', authHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
        
        req.setBody('text=' + EncodingUtil.urlEncode(messageUpdate, 'UTF-8') + '&' + 'screen_name=' + endUserScreenName);
        
        HttpResponse res = getResponse(req);

        return res.getStatusCode() != 200 ? res.getBody() : '';
     }
     
     //method to send the response
     private HttpResponse getResponse(HttpRequest req) {
     	Http httpObj = new Http();
        HTTPResponse res = Test.isRunningTest() ? new Httpresponse() : httpObj.send(req);
        return res;
     }
     
     //Wrapper Class to handle the OAuth tokens
     public class OAuthWrapper {
        public String consumerKey {get; set;}
        public String consumerSecret {get; set;}
        public String accessToken {get; set;}
        public String accessSecret {get; set;}
        public String dmReceiver {get;set;}
        public String directMessage {get; set;}
        
        //Default Cons
        public OAuthWrapper() {
            this.consumerKey = '';
            this.consumerSecret = '';
            this.accessToken = '';
            this.accessSecret = '';
            this.dmReceiver = '';
            this.directMessage = '';
        }
        
        //Params Cons
        public void setOauthTokens(String consumerKey, String consumerSecret, String accessToken,
            String accessSecret, String dmReceiver, String directMessage) {
            this.consumerKey = consumerKey != null ? consumerKey : '';
            this.consumerSecret = consumerSecret != null ? consumerSecret : '';
            this.accessToken = accessToken != null ? accessToken : '';
            this.accessSecret = accessSecret != null ? accessSecret : '';
            this.dmReceiver = dmReceiver != null ? dmReceiver : '';
            this.directMessage = directMessage != null ? directMessage : '';
        }
        
        //ToString wrapper for debugging purposes
        public String[] toStringWrapper() {
            String[] debugStr = new String[2];
            String oAuthCredentials = 'Consumer Key:'+this.consumerKey+' Consumer Secret:'+this.consumerSecret+
                'Access Token:'+accessToken+' Access Secret:'+accessSecret;
            String debugDM = 'DM Receiver:'+dmReceiver+' Direct Message:'+directMessage;
            
            debugStr[0] = oAuthCredentials;
            debugStr[1] = debugDM;
            return debugStr;
        }
     }
}