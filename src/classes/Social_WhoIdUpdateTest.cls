@istest
public class Social_WhoIdUpdateTest
{

    public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case');
//test method for Social_Activate_User Class  
    public static TestMethod void Social_WhoIdUpdateTestMethod()
    {
        
          Profile p1 = [select id, name from profile where name='Care Manager Business'];
         
          Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User',email = 'test123@ayahoo.com' );
          insert contactObj; 
          
          User u2 = new User(alias = 's155', email='standarduser123456@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p1.Id, isactive=true,
          timezonesidkey='America/Los_Angeles', Availability__c='Available', 
          username='standarduser123456@accenture.com');          
          insert u2;
          
            Case singleCase = new Case();
            singleCase.Status = 'Closed';
            singleCase.OwnerId = u2.Id;
            singleCase.Business_Case_Post_Tag__c = 'GCS-GEN';
            singleCase.Social_Media_Source__c = 'ATT Small Biz';
            singleCase.Component_Primary__c = 'DSL';
            singleCase.RecordTypeId = caseRecordTypeId;
            singleCase.Customer_Type__c= 'Enterprise';
            singleCase.Effort__c= 'Simple';
            singleCase.Reason = 'Resolved';
            singleCase.Clarify_CRM_Verified__c = 'No';          
            insert singleCase;
          
          Forsee_Survey__c fObj = new Forsee_Survey__c( Contact__c = contactObj.Id, Case__c = singleCase.Id ,One_Time_Used__c = false , URL_Active__c = true);
          insert fObj ;
          
          TIMBASURVEYS__Survey_Summary__c singleSurvey = new TIMBASURVEYS__Survey_Summary__c();
          singleSurvey.TIMBASURVEYS__RelatedCase__c = singleCase.Id;
          
          insert singleSurvey;
    }
}