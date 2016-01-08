@isTest
global class Url_Shortener_Ctr_V2_Test {


global class HttpResponseGen implements HttpCalloutMock {

    public String body = '';
    public Integer statusCode = 567;

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        res.setBody(body);
        res.setStatusCode(statusCode);

        return res;
    }
}



    static Url_Shortener_Ctr_v2 ctrl;
    static HttpResponseGen mock;
    static bitly_login__c bitly_login;

    static void populateEnvironment(){
    
        bitly_login = new bitly_login__c(name = 'bitly_login', active__c = true, username__c = 'gpivotto', password__c = 'password');
        insert bitly_login;

        ctrl = new Url_Shortener_Ctr_v2();
        mock = new HttpResponseGen();
        ctrl.username = '';
        ctrl.password = '';
        ctrl.inputUrl = 'http://www.elpais.com';

    }


    static testMethod void testLoginBlankUser(){

        System.Test.startTest();

            //Test blank user and pass
            populateEnvironment();

            ctrl.getLogin();

            System.assertEquals(ctrl.access_token, null);

        System.Test.stopTest();
    }


    static testMethod void testLoginInvalidUser(){
        populateEnvironment();

        System.Test.startTest();
            //Test invalid user and pass

            mock.body = '{"status_code": 200, "data": null, "status_txt": "INVALID_LOGIN"}';
            mock.statusCode = 200;

            System.Test.setMock(HttpCalloutMock.class, mock);

            ctrl.username = 'George';
            ctrl.password = 'Nopass';

            ctrl.getLogin();

            System.assertEquals(ctrl.access_token, null);

        System.Test.stopTest();
    }

    static testMethod void testLoginValidUser(){
        populateEnvironment();

        System.Test.startTest();
            //Test valid user and pass

            mock.body = '5c5f3154e69121144f9118abc8fb127aae719e30';
            mock.statusCode = 200;

            System.Test.setMock(HttpCalloutMock.class, mock);

            ctrl.username = 'gpivotto';
            ctrl.password = 'password';

            ctrl.getLogin();

            System.assertEquals(ctrl.access_token, '5c5f3154e69121144f9118abc8fb127aae719e30');

         System.Test.stopTest();
    }

    static testMethod void testLoginConnectionFail(){
        populateEnvironment();

        System.Test.startTest();
            //Test connection fail

            mock.body = '{"status_code": 200, "data": null, "status_txt": "CONNECTION_FAILED"}';
            mock.statusCode = 200;

            List<SelectOption> options = ctrl.getServices();

            System.Test.setMock(HttpCalloutMock.class, mock);

            
            ctrl.username = 'gpivotto';
            ctrl.password = 'password';

            ctrl.getLogin();

            System.assertEquals(ctrl.access_token, null);

         System.Test.stopTest();
    }

   static testMethod void testBitlyShortUrl(){
            populateEnvironment();

            System.Test.startTest();
                mock.body = '{"status_code": 200, "status_txt": "OK", "data": { "long_url": "http://www.elpais.com/","url": "http://bit.ly/1qHQMnP", "hash": "1qHQMnP", "global_hash": "9UWAL8", "new_hash": 0 } }';
                mock.statusCode = 200;

                System.Test.setMock(HttpCalloutMock.class, mock);

                ctrl.getLogin();
                ctrl.access_token = '5c5f3154e69121144f9118abc8fb127aae719e30';
                ctrl.getBitlyShortUrl();

                System.assertEquals(ctrl.shortUrl, 'http://bit.ly/1qHQMnP');

            System.Test.stopTest();
    }

    static testMethod void testGetTinyShortUrl(){
            populateEnvironment();

            System.Test.startTest();
                mock.body = 'http://tinyurl.com/23ohg';
                mock.statusCode = 200;

                System.Test.setMock(HttpCalloutMock.class, mock);

                ctrl.getTinyShortUrl();

                System.assertEquals(ctrl.shortUrl, 'http://tinyurl.com/23ohg');

            System.Test.stopTest();
    }

    static testMethod void chooseService(){
        System.Test.startTest();
            ctrl = new Url_Shortener_Ctr_v2();
            ctrl.chooseService();

            System.assertEquals(ctrl.shortUrl, '');
            System.assertEquals(ctrl.inputUrl, 'http://');

            System.assertEquals(ctrl.service, null);
            System.assertEquals(ctrl.access_token, null);
        System.Test.stopTest();

    }

    static testMethod void testClear(){
        System.Test.startTest();
            ctrl = new Url_Shortener_Ctr_v2();
            ctrl.clear();

            System.assertEquals(ctrl.shortUrl, '');
            System.assertEquals(ctrl.inputUrl, 'http://');
        System.Test.stopTest();
    }

}