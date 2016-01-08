@isTest(seeAllData= true)
private class Social_CaseAudit_Test{
    public static Case c;
    public static Case c1;
    public static Case c2;
    static User u;
    static User u1;
  
   static{
    
    Profile p = [select id from profile where name='Operations Manager'];
    
    u = new User(alias = 's125', email='standarduser125@testorg.com',
    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
    localesidkey='en_US', profileid = p.Id, isactive=true,
    timezonesidkey='America/Los_Angeles', username='standarduser125@accenture.com');
    insert u;
    
    Profile p1 = [select id from profile where name='Senior Operations Manager Business'];
    
    u1 = new User(alias = 's126', email='standarduser126@testorg.com',
    emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
    localesidkey='en_US', profileid = p1.Id, isactive=true,
    timezonesidkey='America/Los_Angeles',username='standarduser126@accenture.com');
    insert u1; 
    
    c=new Case();
    c.Status='New';
    c.Type='phone';
    c.Priority='High';
    c.Origin='Phone';
    c.ownerId=u.id;
    c.Audit_Status__c='Under QA';
    
    insert c; 
    
    c1=new Case();
    c1.Status='New';
    c1.Type='phone';
    c1.Priority='High';
    c1.Origin='Email Business (BizHelp)';
    c1.ownerId=u1.id;
    c1.Audit_Status__c='Under QA';
    insert c1; 
  }
  
    static testMethod void Social_CaseAudit(){
        Test.startTest();
        Social_CaseAudit cAudit = new Social_CaseAudit();
        cAudit.isError = false;
        cAudit.isScoreZero2 = false;
        cAudit.isScoreZero = false;
        cAudit.isCaseTrack=false;
        cAudit.isBusScoreZero = false;
        cAudit.isBusScoreZero2 = false; 
        cAudit.isBusinessCare = false;  
        Audit_Question__c audit = new Audit_Question__c();
        audit.Audit_Question_Type__c ='Consumer Care';
        audit.Name='Test';
        audit.Question__c='Did the SMM VID the account?';
        audit.Coaching__c ='good';
        audit.Answer__c ='Yes';
        audit.Score__c =0;
        audit.Component__c ='Customer Interaction';
        audit.Active__c ='Yes';
        audit.Auto_Fail__c ='Yes';
        
        insert audit;
        
        Audit_Responses__c rep = new Audit_Responses__c();
        rep.Audit_Question_Type__c = audit.Audit_Question_Type__c;
        rep.Audit_Question__c = audit.Question__c;
        rep.Audit_Coaching__c = audit.Coaching__c;
        rep.Audit_Answer__c = audit.Answer__c;
        rep.Audit_Component__c = audit.Component__c;
        rep.Case__c=c.id;
        insert rep;
        
        Test.stopTest();
    }
    
    static testMethod void Social_CaseAudit1(){ 
        Test.startTest();
        Social_CaseAudit cAudit = new Social_CaseAudit();
        cAudit.isError = false;
        cAudit.isScoreZero2 = false;
        cAudit.isScoreZero = false;
        cAudit.isCaseTrack=false;
        cAudit.isBusScoreZero = false;
        cAudit.isBusScoreZero2 = false; 
        cAudit.isBusinessCare = false;
        
        c.Audit_Status__c='QA Completed';
         
                    
        update c;
        
        ApexPages.currentPage().getParameters().put('Id', c.id);
        Social_CaseAudit  testcase = new Social_CaseAudit(new ApexPages.StandardController(c));  
        String str='Please provide the answer for all QA questions.';
        boolean isBusinessCare  = false;
        boolean isScoreZero =true;
        boolean isError=true;
        testcase.isCaseAudited();
        testcase.getIsAuditComplete();
        testcase.getItems();
        testcase.getAuditQuestions();
        testcase.setError(str);
        testcase.getError();
        testcase.saveAudit();
        testcase.cancel();
        Test.stopTest();
    }
 
  
    static testMethod void Social_CaseAudit2(){
        Test.startTest();
        Social_CaseAudit cAudit = new Social_CaseAudit();
        cAudit.isError = true;
        cAudit.isScoreZero2 = true;
        cAudit.isScoreZero = true;
        cAudit.isCaseTrack=true;
        cAudit.isBusScoreZero = true;
        cAudit.isBusScoreZero2 = true; 
        cAudit.isBusinessCare = true; 
    
        Audit_Question__c audit = new Audit_Question__c();
        audit.Audit_Question_Type__c ='Consumer Care';
        audit.Name='Test';
        audit.Question__c='Did the SMM VID the account?';
        audit.Coaching__c ='good';
        audit.Answer__c ='No';
        audit.Score__c =0;
        audit.Component__c ='Customer Interaction';
        audit.Active__c ='Yes';
        
       
        insert audit;
        
        Audit_Responses__c rep = new Audit_Responses__c();
        rep.Audit_Question_Type__c = audit.Audit_Question_Type__c;
        rep.Audit_Question__c = audit.Question__c;
        rep.Audit_Coaching__c = audit.Coaching__c;
        rep.Audit_Answer__c = audit.Answer__c;
        rep.Audit_Component__c = audit.Component__c;
        rep.Case__c=c.id;
        insert rep;
        Test.stopTest();
    }
    
    static testMethod void Social_CaseAudit3(){
        Test.startTest();
        Social_CaseAudit cAudit = new Social_CaseAudit();
        cAudit.isError = false;
        cAudit.isScoreZero2 = false;
        cAudit.isScoreZero = false;
        cAudit.isCaseTrack=false;
        cAudit.isBusScoreZero = true;
        cAudit.isBusScoreZero2 = false; 
        cAudit.isBusinessCare = false; 
        
        c.Audit_Status__c='QA Completed';
                     
        update c;
        
        ApexPages.currentPage().getParameters().put('Id', c.id);
        Social_CaseAudit  testcase = new Social_CaseAudit(new ApexPages.StandardController(c));  
        String str='Please provide the answer for all QA questions.';
        //boolean isBusinessCare = false;
        //boolean isScoreZero =true;
        //boolean isError=true;
        testcase.isCaseAudited();
        testcase.getIsAuditComplete();
        testcase.getItems();
        testcase.getAuditQuestions();
        testcase.setError(str);
        testcase.getError();
        testcase.saveAudit();
        testcase.cancel();
        Test.stopTest();
    }
 //@@@@@@@@@@@@--Business---@@@@@@@@@@@@@--
 
    static testMethod void Social_CaseAudit4(){
        Test.startTest();
        Social_CaseAudit cAudit = new Social_CaseAudit();
        cAudit.isError = false;
        cAudit.isScoreZero2 = false;
        cAudit.isScoreZero = false;
        cAudit.isCaseTrack=false;
        cAudit.isBusScoreZero = false;
        cAudit.isBusScoreZero2 = false; 
        cAudit.isBusinessCare = false;  

        Audit_Question__c audit = new Audit_Question__c();
        audit.Audit_Question_Type__c = 'Business Care';
        audit.Name='Test';
        audit.Question__c='Did the SMM utilize self-support link if appropriate?';
        audit.Coaching__c ='good';
        audit.Answer__c ='Yes';
        audit.Score__c =10;
        audit.Component__c ='Customer Interaction';
        audit.Active__c ='Yes';
       
        insert audit;
        
        Audit_Responses__c rep = new Audit_Responses__c();
        rep.Audit_Question_Type__c = audit.Audit_Question_Type__c;
        rep.Audit_Question__c = audit.Question__c;
        rep.Audit_Coaching__c = audit.Coaching__c;
        rep.Audit_Answer__c = audit.Answer__c;
        rep.Audit_Component__c = audit.Component__c;
        rep.Case__c=c.id;
        insert rep;
         
        Test.stopTest();
    }
    
    static testMethod void Social_CaseAudit5(){
        Test.startTest();
        Social_CaseAudit cAudit = new Social_CaseAudit();
        cAudit.isError = false;
        cAudit.isScoreZero2 = false;
        cAudit.isScoreZero = false;
        cAudit.isCaseTrack=false;
        cAudit.isBusScoreZero = false;
        cAudit.isBusScoreZero2 = false; 
        cAudit.isBusinessCare = false; 
       
         
        c1.Audit_Status__c='QA Completed';              
        update c1;
        
        ApexPages.currentPage().getParameters().put('Id', c1.id);
        Social_CaseAudit  testcase = new Social_CaseAudit(new ApexPages.StandardController(c1));  
        String str='Please provide the answer for all QA questions.';
        //boolean isBusinessCare  = True;
        //boolean isScoreZero2 = false;
        //boolean isError=true;
        testcase.isCaseAudited();
        testcase.getIsAuditComplete();
        testcase.getItems();
        testcase.getAuditQuestions();
        testcase.setError(str);
        testcase.getError();
        boolean isBusinessCare  = True;
        testcase.saveAudit();
        testcase.cancel();
        Test.stopTest();
    }
 
  
    static testMethod void Social_CaseAudit6(){
        Social_CaseAudit cAudit = new Social_CaseAudit();
        Test.startTest();
        cAudit.isError = false;
        cAudit.isScoreZero2 = false;
        cAudit.isScoreZero = false;
        cAudit.isCaseTrack=false;
        cAudit.isBusScoreZero = false;
        cAudit.isBusScoreZero2 = false; 
        cAudit.isBusinessCare = false; 
    
       
        Audit_Question__c audit = new Audit_Question__c();
        audit.Audit_Question_Type__c = 'Business Care';
        audit.Name='Test';
        audit.Question__c='Did the SMM utilize self-support link if appropriate?';
        audit.Coaching__c ='good';
        audit.Answer__c ='No';
        audit.Score__c =0;
        audit.Component__c ='Customer Interaction';
        audit.Active__c ='Yes';
       
        insert audit;
        
        Audit_Responses__c rep = new Audit_Responses__c();
        rep.Audit_Question_Type__c = audit.Audit_Question_Type__c;
        rep.Audit_Question__c = audit.Question__c;
        rep.Audit_Coaching__c = audit.Coaching__c;
        rep.Audit_Answer__c = audit.Answer__c;
        rep.Audit_Component__c = audit.Component__c;
        rep.Case__c=c.id;
        insert rep;
        Test.stopTest();
    }
    
    static testMethod void Social_CaseAudit7(){
        Test.startTest();
        Social_CaseAudit cAudit = new Social_CaseAudit();
        cAudit.isBusinessCare = true; 
       /* cAudit.isError = true;
        cAudit.isScoreZero2 = true;
        cAudit.isScoreZero = true;
        cAudit.isCaseTrack=true;
        cAudit.isBusScoreZero = true;
        cAudit.isBusScoreZero2 = true; 
       */ 
         
        c1.Audit_Status__c='QA Completed';              
        update c1;
        
        ApexPages.currentPage().getParameters().put('Id', c1.id);
        Social_CaseAudit  testcase = new Social_CaseAudit(new ApexPages.StandardController(c1));  
        String str='Please provide the answer for all QA questions.';
        //boolean isBusinessCare  = True;
        //boolean isScoreZero2 = false;
        //boolean isError=true;
        testcase.isCaseAudited();
        testcase.getIsAuditComplete();
        testcase.getItems();
        testcase.getAuditQuestions();
        testcase.setError(str);
        testcase.getError();
        boolean isBusinessCare  = false;
        testcase.saveAudit();
        testcase.cancel();
        Test.stopTest();
    }
    static testMethod void Social_CaseAudit8(){
        c2=new Case();
        c2.Status='Closed';
        c2.reason = 'Completed';
        c2.Component_Primary__c = 'Unknown';
        c2.Component_Secondary__c = 'Unknown';
        c2.Case_Post_Tag__c = 'GENERAL';
        c2.Social_Media_Source__c = 'Twitter';
        c2.Type='phone';
        c2.Priority='High';
        c2.Origin='Phone';
        c2.ownerId=u.id;
        c2.Audit_Status__c='Under QA';
        insert c2; 
        
        Audit_Question__c audit1 = new Audit_Question__c();
        audit1.Audit_Question_Type__c = 'Business Care';
        audit1.Name='Test';
        audit1.Question__c='Did the SMM utilize self-support link if appropriate?';
        audit1.Coaching__c ='good';
        audit1.Answer__c ='No';
        audit1.Score__c =0;
        audit1.Component__c ='Customer Interaction';
        audit1.Active__c ='Yes';
       
        insert audit1;
        
        Audit_Responses__c rep1= new Audit_Responses__c();
        rep1.Audit_Question_Type__c = audit1.Audit_Question_Type__c;
        rep1.Audit_Question__c = audit1.Question__c;
        rep1.Audit_Coaching__c = audit1.Coaching__c;
        rep1.Audit_Answer__c = audit1.Answer__c;
        rep1.Audit_Component__c = audit1.Component__c;
        rep1.Case__c=c2.id;
        insert rep1;
        
        ApexPages.currentPage().getParameters().put('Id', c2.id);
        Social_CaseAudit  testcase1 = new Social_CaseAudit(new ApexPages.StandardController(c2));  
        String str='Please provide the answer for all QA questions.';
        testcase1.isCaseAudited();
        
    }
    
    
}