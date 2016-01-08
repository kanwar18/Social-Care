@istest(seealldata=false)
private class TEST_Social_CreateDefect
{
static testmethod void Social_CreateDefect()
{  

test.starttest();
   
   
    
   Defect_Logs__c deflog= new Defect_Logs__c();
//   'Case Post Tags'
   deflog.Resolution_Notes__c='asdfsad';  
   deflog.Defect_Subject__c='vdhfd';
   deflog.Severity__c='2 - High';
   deflog.Steps_to_Reproduce_Error__c='sadfasd';
   deflog.Impact__c='sadfasdfsa';
   deflog.Status__c='Open';
   deflog.Logged_Date_Time__c=datetime.now();
   deflog.Related_to__c='Case Post Tags';
   
   insert deflog;
       
   ApexPages.StandardController StdCtrl = new ApexPages.StandardController(deflog);
   Social_CreateDefect socclasinst=new Social_CreateDefect(StdCtrl);
   
   socclasinst.CreateITSupTicket();

test.stoptest();
}
}