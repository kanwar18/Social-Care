@isTest
global class URL_Shortener_SetupCtr_Test {

    static URL_Shortener_SetupCtr ctrl;
    static bitly_login__c bitly_login;

    static void populateEnvironment(){
    
        bitly_login = new bitly_login__c(name = 'bitly_login', active__c = true, username__c = 'gpivotto', password__c = 'password');
        insert bitly_login;

    }


    static testMethod void testSetup(){
            populateEnvironment();

            System.Test.startTest();
                URL_Shortener_SetupCtr ctr = new URL_Shortener_SetupCtr();

                System.assertEquals(ctr.setupObj.password__c, 'password');

            System.Test.stopTest();
    }
    
    static testMethod void testSave(){
            populateEnvironment();

            System.Test.startTest();
                URL_Shortener_SetupCtr ctr = new URL_Shortener_SetupCtr();
                
                ctr.setupObj.password__c = 'pass';
                ctr.Save();
                 ctr.checkCustomSetting();

                System.assertEquals(ctr.setupObj.password__c, 'pass');

            System.Test.stopTest();
    }
    
    
    static testMethod void testGetter(){
            populateEnvironment();

            System.Test.startTest();
                bitly_login__c login = URL_Shortener_SetupCtr.getSetupObject(); 

                System.assertNotEquals(login, null);

            System.Test.stopTest();
    }



}