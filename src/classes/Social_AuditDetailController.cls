public class Social_AuditDetailController{
    public id idd;
    public String caseManager {get;set;}
    public Audit_Responses__c auditObj { get; set; }
    public String userName  {get;set;}
    public User u {get;set;}
    
    public Social_AuditDetailController(ApexPages.StandardController Controller){
            idd=ApexPages.currentPage().getParameters().get('id');
            auditObj = [Select Id, Case__c, Case__r.Closed_Operation_Manager__c,  Audit_Answer__c from Audit_Responses__c where id=:Idd];
            caseManager = auditObj.Case__r.Closed_Operation_Manager__c;
            System.debug('XXXXXXXXXXXXXXX--'+caseManager);
            System.debug('cccccccc--'+caseManager);
            profileSettings();       
    }
    
    public void profileSettings() {
        u = [select id, Name from User where id=: Userinfo.getUserId()];
        userName =u.Id;    
    }    
    








}