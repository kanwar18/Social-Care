public class Social_CreateDefect
{

public Defect_Logs__c mdeflog { get; set;}// variable used to store current instance of defectlogs
public boolean actionflag {get;set;}

    public Social_CreateDefect(ApexPages.StandardController controller)
        {
        actionflag =false;
        mdeflog =(Defect_Logs__c)controller.getRecord();
        }

    public pagereference CreateITSupTicket()
        {
        IT_Support_Ticket__c ITSupTick=new IT_Support_Ticket__c();
                      try
     {   
        List<Defect_Logs__c> ldeflog=[select IT_Support_Ticket__c ,Description__c,Resolution_Notes__c,Resolution_Owner__c,Resolution_Provider__c,Added_Screenshot_as_Note_Attachment__c,Target_Resolution_Date__c,Status__c,Logged_Date_Time__c,Steps_to_Reproduce_Error__c,Defect_Subject__c,Severity__c,Actual_Resolution_Date_Time__c,Business_Group__c,Change_Request__c,Closed_Reasons__c,Impact__c,Error_Message_Received__c,Related_to__c,Owner_Work_Phone__c,Related_Salesforce_Support_Case__c from Defect_Logs__C where ID=:mdeflog.id ];
       
        ITSupTick.Resolution_Notes__c=ldeflog[0].Resolution_Notes__c;
        ITSupTick.Logged_Date_Time__c=ldeflog[0].Logged_Date_Time__c;
        ITSupTick.Resolution_Provider__c=ldeflog[0].Resolution_Provider__c;
        ITSupTick.Added_Screenshot_as_Note_Attachment__c=ldeflog[0].Added_Screenshot_as_Note_Attachment__c;
        ITSupTick.Target_Resolution_Date__c=ldeflog[0].Target_Resolution_Date__c;
        ITSupTick.Status__c=ldeflog[0].Status__c;
        ITSupTick.Ticket_Subject__c=ldeflog[0].Defect_Subject__c;
        ITSupTick.Severity__c=ldeflog[0].Severity__c;
        ITSupTick.Impact__c=ldeflog[0].Impact__c;
        ITSupTick.Steps_to_Reproduce_Error__c=ldeflog[0].Steps_to_Reproduce_Error__c;
        ITSupTick.Actual_Resolution_Date_Time__c=ldeflog[0].Actual_Resolution_Date_Time__c;
        ITSupTick.Business_Group__c=ldeflog[0].Business_Group__c;
        ITSupTick.Error_Message_Received__c=ldeflog[0].Error_Message_Received__c;
        ITSupTick.Related_to__c=ldeflog[0].Related_to__c;
        ITSupTick.Owner_Work_Phone__c=ldeflog[0].Owner_Work_Phone__c;
        ITSupTick.Related_Salesforce_Support_Case__c=ldeflog[0].Related_Salesforce_Support_Case__c;
        ITSupTick.Description__c = ldeflog[0].Description__c;
    
       insert ITSupTick;
                  }
            catch(Exception excep) {
                System.debug('Exception Caught from Insert of new IT Support Ticket:'+ excep.getMessage());
                                   }  
        
        List<IT_Support_Ticket__c> lITsupTick =[select id from IT_Support_Ticket__c order by createddate desc limit 1];
        
        mdeflog.IT_Support_Ticket__c = lITsupTick[0].id;
        try
        {
        update mdeflog ;
        }
        catch(Exception excep) {
                System.debug('Exception Caught from update:'+ excep.getMessage());
                               } 
        
        PageReference deflogpage = new PageReference('/' + lITsupTick[0].id);
        deflogpage.setRedirect(true);
        return deflogpage ;
        
}
}