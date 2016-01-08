@isTest
public class Social_CaseRedirectControllerTest{
    static Case newCase;
    static{
        newCase =  new Case();
        newCase.Status='New';
        newCase.Origin='Social Hub';
        newCase.case_posttag__c = 'SWITCHER NON - AT&T';
        insert newCase;  
    }
    public static testMethod void RedirectTestMethod(){
        ApexPages.StandardController controller =  new ApexPages.StandardController(newCase);
        Social_CaseRedirectController testObj =  new Social_CaseRedirectController(controller);
    }

}