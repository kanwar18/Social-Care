public Class Social_AuditEditController{
    public Id id;
    public Id CaseId{get;set;}
    public Audit_Responses__c auditObj {get; set; }
    

    public Social_AuditEditController(ApexPages.StandardController Controller){
       id=ApexPages.currentPage().getParameters().get('id');
       auditObj = [Select Id, Case__c, Audit_Answer__c ,Audit_Coaching__c from Audit_Responses__c where id=:Id];
       CaseId = auditObj.Case__c; 
    }
   
    /*Redirecting the case detail page when click cancel button */
    public pageReference cancel(){
        PageReference casePage = new PageReference('/'+CaseId);
        casePage.setRedirect(true);
        return casePage; 
    }
  
    /*Redirecting the case detail page when click cancel button */
    public void save(){
        try {
             update auditObj;
         }catch (Exception e) {
            ApexPages.addMessages(e);
         } 
    }   
}