/*** Class Name: Social_AuditCase 
 * Author: Accenture
 * Date: 15-Oct-2012
 * Requirement/Project Name: Social Care
 * Requirement Description:This apex class is using to dispalying all audit question and respective
 * components, choaching/comments and score on the visual force page when Operations Manager click 
 * audit for auditing and creating the audit responses records based on provided audit question. 
 **/
public Class Social_CaseAudit{
    public Id id;
    public List<Audit_Question__c> qlist;
    public string answer{get;set;}
    public Boolean isErrorcheck{get;set;}
    public Case caseDetail;
    Public String error='';
    public Boolean isError=false;
    public boolean isScoreZero = false;
    public boolean isScoreZero2 = false;  
    public List<Case> auditedCase = new List<Case>();
    public List<Audit_Responses__c> auditResponsesList;
    public Boolean isCaseTrack=false;
    public Integer count =0;
    public Integer pCount =0;

    public list<socialPost> socialPostList;
    
    public List<Audit_Question__c> qBusList;
    public boolean isBusScoreZero = false;
    public boolean isBusScoreZero2 = false;  
    public boolean isBusinessCare {get;set;}
    public String businessCare {get;set;}
    public string CaseId {get;set;}
    
    public Social_CaseAudit(ApexPages.StandardController Controller){
        id=ApexPages.currentPage().getParameters().get('id');
        getAuditQuestions();
        getSocialPostList();
        checkBusinessCare();
        getBusAuditQuestions();

        
    }
    
    public Social_CaseAudit(){
    
    }
    
    public void checkBusinessCare() {
        isBusinessCare = false;
        Case c = [select id, RecordTypeId from Case where id=:Id];
        businessCare  = c.RecordTypeId;        
        if(businessCare==Label.Business_Case_Audit_Record_Type_ID){
            isBusinessCare = true;          
          }
     }
    
    /* updating the value of Audit Status field on Case object   */
    public void isCaseAudited(){     
       for(Case isCaseAudited : [select Id, No_Of_Audit_Responses__c, Audit_Status__c from Case where isClosed =:true AND Id=:Id]){
            if(isCaseAudited.No_Of_Audit_Responses__c>0){
                isCaseAudited.Audit_Status__c='QA Completed';
                auditedCase.add(isCaseAudited);
                caseId=isCaseAudited.id;
                isErrorcheck=false;  
             }   
        }
        update auditedCase;
    } 
    
   
   /* checking that case has audited or not */
    public boolean getIsAuditComplete(){
        boolean isComplete;
        auditResponsesList  = [select name,Id,Case__c from Audit_Responses__c where Case__c =:Id];
        if(auditResponsesList.size()>0){
            isComplete = true;
        }
        else{
            isComplete= false;
        }
        return isComplete;
    }
   
    /* converting the value in radio button format from picklist format of Answer field */
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        options.add(new SelectOption('NA','NA'));
        return options;
    }    
    
    /* Reterving the list from Audit Question object to displaying these values on the CaseAudit visual force page */
    public List<Audit_Question__c> getAuditQuestions(){
        if(qlist  == null)
        //qlist  =[Select Id, Name, Question__c, Coaching__c,Answer__c, Score__c, Component__c from Audit_Question__c where Active__c=:'Yes' Order By Component__c ASC];
        qlist  =  [Select Id, Name, Question__c,Coaching__c, Answer__c, Score__c, Component__c from Audit_Question__c where Active__c=:'Yes' AND Audit_Question_Type__c=:'Consumer Care' Order By Component__c ASC];
        return qlist;
    }
    /* Reterving the Business Audit Question list from Audit Question object
     to displaying these values on the CaseAudit visual force page */
    public List<Audit_Question__c> getBusAuditQuestions(){
        if(qBusList == null) 
        qBusList =[Select Id, Name, Question__c, Coaching__c, Answer__c, Score__c, Component__c from Audit_Question__c where Active__c=:'Yes'AND Audit_Question_Type__c=:'Business Care' Order By Component__c ASC];
        return qBusList;
    }
    
    public void setError(String errorMesg){
       error=errorMesg;
    }
    public String getError(){
       return error;
    }
   //Creating audit responses records based on provided audit answers of all audit questions.
   Public pageReference saveAudit(){  
        set<string> zeroScoreQuestions = new set<string>();
        for(Audit_Question__c  x: [select Question__c,   Auto_Fail__c from audit_question__c where   Auto_Fail__c =:'Yes']) {
                zeroScoreQuestions.add(x.Question__c);
        }
        set<string> zeroScoreQuestions2 = new set<string>();
        for(Audit_Question__c  y: [select Question__c,   Auto_Fail__c, DecreasingScore__c from audit_question__c where   DecreasingScore__c =:'Yes']) {
            zeroScoreQuestions2.add(y.Question__c);
        }
        list<Audit_Responses__c> UserResp1 = new list<Audit_Responses__c>();       
        list<Audit_Responses__c> UserResp = new list<Audit_Responses__c>();
        
        if(isBusinessCare == true){       
        for(Audit_Question__c a : qBusList){
            isScoreZero2 = false;
            Audit_Responses__c res = new Audit_Responses__c();
            res.Audit_Question__c = a.Question__c;
            res.Audit_Coaching__c = a.Coaching__c;
            res.Audit_Answer__c = a.Answer__c;
            res.Audit_Component__c = a.Component__c;
            res.Case__c=Id;
            if(a.Score__c !=Null){
                    if(res.Audit_Answer__c =='Yes'){
                    res.Audit_Score__c=a.Score__c;                   
                    //res.Possible_Audit_Rersponse_Score__c = a.Score__c;                   
                    }
                    else if(res.Audit_Answer__c =='No')
                    {
                      res.Audit_Score__c = 0;                      
                      //res.Possible_Audit_Rersponse_Score__c = a.Score__c;                     
                    }
                    else if(res.Audit_Answer__c =='NA')
                    {
                      res.Audit_Score__c =0;                    
                      //res.Possible_Audit_Rersponse_Score__c = 0;                      
                    }
                    If(zeroScoreQuestions.contains(a.Question__c) && a.answer__c=='No'){ 
                        isScoreZero=true;   
                    }
                    If(zeroScoreQuestions2.contains(a.Question__c) && a.answer__c=='No'){ 
                        res.Audit_score__c = -40;
                        isScoreZero2=true;   
                    }
                        
                }
         userResp.add(res);         
         }
      } else if(isBusinessCare == false){
            for(Audit_Question__c a : qlist){
                isScoreZero2 = false;
                Audit_Responses__c res = new Audit_Responses__c();
                res.Audit_Question__c = a.Question__c;
                res.Audit_Coaching__c = a.Coaching__c;
                res.Audit_Answer__c = a.Answer__c;
                res.Audit_Component__c = a.Component__c;
                res.Case__c=Id;
                if(a.Score__c !=Null){
                    if(res.Audit_Answer__c =='Yes'){
                    res.Audit_Score__c=a.Score__c;                    
                    //res.Possible_Audit_Rersponse_Score__c = a.Score__c;                   
                    }
                    else if(res.Audit_Answer__c =='No')
                    {
                      res.Audit_Score__c = 0;                      
                      //res.Possible_Audit_Rersponse_Score__c = a.Score__c;                      
                    }
                     else if(res.Audit_Answer__c =='NA')
                    {
                      res.Audit_Score__c =0;                     
                      //res.Possible_Audit_Rersponse_Score__c = 0;                      
                    }
                    If(zeroScoreQuestions.contains(a.Question__c) && a.answer__c=='No'){ 
                        isScoreZero=true;   
                    }
                    If(zeroScoreQuestions2.contains(a.Question__c) && a.answer__c=='No'){ 
                        res.Audit_score__c = -40;
                        isScoreZero2=true;   
                    }
                        
                }                                         
                            
                userResp.add(res);
           }
         }
      for(Audit_Responses__c auditCases: userResp){             
          if(auditCases.Audit_Answer__c =='' || auditCases.Audit_Answer__c ==null){
            setError('Please provide answers for all the QA questions.');
            isError=true;
            isErrorcheck=true;
            return null;
            
        }
        else if(isScoreZero){
            auditCases.Audit_score__c = 0;
            userResp1.add(auditCases);    
        }
       }      
       if(isScoreZero){
           insert userResp1;
           
       } 
       else{
           insert userResp;           
                                 
       }
              
       isCaseAudited();  
       return null;     
    }
   /*Redirecting the case detail page when click cancel button */
    public pageReference cancel(){
        caseId=Id;
        return null;
        
    }
    /* This method is used to display the social post detail on the audit page. */
    public list<SocialPost> getSocialPostList(){
        SocialPostList = [select Name, Content, PersonaId,WhoId, Headline, Posted, CreatedDate from SocialPost where ParentId =:Id ];
        return SocialPostList;
    }
    
        
    
}