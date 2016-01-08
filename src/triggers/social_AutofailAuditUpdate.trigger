trigger social_AutofailAuditUpdate on Audit_Responses__c (after Insert, after Update) {

    public boolean isAutoFail = false;
    public boolean isNonAutoFail = false;  
        if(RecursionController.controller == true){
            RecursionController.controller=false;
            SocialCareAudit.getInstance().doValidateAuditResponses(Trigger.New);
            list<id> caseAutofailId  = new list<id>();
            list<id> caseId  = new list<id>();
            List<String> respIdList = new List<String>();
            list<Audit_Question__c> failQuestion = [select id, Name,Score__c,  Question__c, Auto_Fail__c from Audit_Question__c where Auto_Fail__c =:'Yes']; 
            list<Audit_Question__c> nonFail = [select id, Name , Score__c,  Question__c, Auto_Fail__c from Audit_Question__c where Auto_Fail__c =:'No']; 

            if(null != failQuestion && failQuestion.size()>0) {
                Set<String> failQuestionIdSet = new Set<String>();
                for(Audit_Question__c aq : failQuestion){
                    failQuestionIdSet.add(aq.Question__c);
                }
                
                String aFailQuestion = failQuestion[0].Question__c;
                for(Audit_responses__c ar : trigger.new){
                    respIdList.add(ar.id);
                    
                    if(ar.Audit_answer__c.equalsIgnoreCase('No') && failQuestionIdSet.contains(ar.Audit_Question__c)){
                        caseAutofailId.add(ar.case__c);  
                    }
                    else if(ar.Audit_answer__c.equalsIgnoreCase('No')){
                         caseId.add(ar.case__c);
                    }
                    else if(ar.Audit_answer__c.equalsIgnoreCase('Yes') ){
                        caseId.add(ar.case__c); 
                    }else if(ar.Audit_answer__c.equalsIgnoreCase('NA') ){
                        caseId.add(ar.case__c); 
                    }
                }
            }
            
            // from the cases get the related autid responses and set the score to zero.
            list<audit_responses__c> updateAutoFailAuditResponses = [select Audit_Answer__c, Audit_score__c, Audit_Question__c from Audit_responses__c where case__c IN :caseAutofailId];
            list<audit_responses__c> updateFailAuditResponses = new list<audit_responses__c>();
            list<audit_responses__c> updateAuditResponses = [select id,Audit_Answer__c, Audit_score__c, Audit_Question__c from Audit_responses__c where case__c IN :caseId];
            list<audit_responses__c> updateAudRes = new list<audit_responses__c>();
            Map<String,integer> scoreMap = new Map<String,integer>();

            for(audit_responses__c  adr : updateAutoFailAuditResponses){
                adr.Audit_score__c=0;
                updateFailAuditResponses.add(adr);
                isAutoFail = true;
            } 
            
            //added for the deployment fix
            String failQId = '';
            if(!failQuestion.isEmpty()) {
                failQId = failQuestion[0].id;
            }
            
            Map<String, Integer> questionsScrore = SocialCareAudit.getInstance().questionsMap;
            for(audit_responses__c  ar : updateAuditResponses){
                  if(String.valueOf(ar.Audit_Answer__c) == 'Yes'){
                      ar.Audit_score__c =  questionsScrore.get(String.valueOf(ar.Audit_Question__c));
                  } 
                  updateAudRes.add(ar);
                  isNonAutoFail = true;
            }
            if(isAutoFail){
                update updateFailAuditResponses;
            }else if(isNonAutoFail){
                update updateAudRes; 
            }
        }
}