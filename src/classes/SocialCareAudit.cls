//A class deals with the Audit Functionality
public class SocialCareAudit {
    public Map<String, Integer> questionsMap = null;
    
    private Map<Id, Map<String, Integer>> aggCasResMap = new Map<Id, Map<String,Integer>>();
    private Map<Id, Case> caseMap = new Map<Id, Case>();
    private List<Audit_Responses__c> auditResList = new List<Audit_Responses__c>();
    private static SocialCareAudit socCareAudit = null;
    private boolean isAutoFailed = FALSE;
    private Set<String> autoFailQuestionSet = new Set<String>();
    
    
    //private cons
    private SocialCareAudit() {
        questionsMap = getAuditQuestionsScore();
    }
    
    //get the current class instance
    public static SocialCareAudit getInstance() {
        if(null == socCareAudit) {
            socCareAudit = new SocialCareAudit();
        }
        return socCareAudit;
    }
    
    //Method to deal with the audit responses
    public void doValidateAuditResponses(SObject[] objectArr) {
        Set<Id> auditResIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        Map<String,Integer> auditResCase = null;
        Id caseIdObj = null;
        Integer yesScore = 0;
        Integer noScore = 0;
        
        try {
            
            //Block to add the id's to the set's
            for(SObject objectObj : objectArr) {
                auditResIdSet.add((Id)objectObj.get('Id'));
                caseIdSet.add((Id) objectObj.get('Case__c'));
            }
            
            //Block to group the cases based on Audit Answer
            for(AggregateResult aggRes :[Select Case__c, Audit_Answer__c,count(Audit_Question__c) 
              queCnt, sum(Audit_Score__c) auditScoreSum from Audit_Responses__c Where Case__c IN :caseIdSet 
              group by Case__c, Audit_Answer__c Order by Case__c]) {
                caseIdObj = (Id) aggRes.get('Case__c');
                auditResCase = (Map<String, Integer>) aggCasResMap.get(caseIdObj);
                if(null == auditResCase) {
                    aggCasResMap.put(caseIdObj, new Map<String, Integer>());
                }
                aggCasResMap.get(caseIdObj).put(String.valueOf(aggRes.get('Audit_Answer__c')), 
                    Integer.valueOf(aggRes.get('auditScoreSum')));
            }
            
            //call to get the cases
            caseMap = getCases(caseIdSet);
            
            //call to get the audit responses
            auditResList = getAuditResponses(caseIdSet);
            
            for(Id caseIdObjLoop : aggCasResMap.keySet()) {
                auditResCase = aggCasResMap.get(caseIdObjLoop);
                if(null != auditResCase) {
                    for(String answerTypeStr : auditResCase.keySet()) {
                        auditResCase.put(answerTypeStr,
                            getScoreAnswersScore(caseIdObjLoop, answerTypeStr));
                    }
                    yesScore = null != auditResCase.get('Yes') ? auditResCase.get('Yes') : 0;
                    noScore = null !=  auditResCase.get('No') ? auditResCase.get('No') : 0;
                    caseMap.get(caseIdObjLoop).put('Possible_Score__c',(yesScore + noScore)); 
                    caseMap.get(caseIdObjLoop).put('Audit_Score__c', yesScore);
                }
            }
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            update caseMap.values();
            
        } catch(Exception excep) {
            System.debug('Exception Caught : Line #+'+excep.getLineNumber()+', '+excep.getMessage());
            throw excep;
        }
    }
    
    //method used to find the score of the answer
    public Integer getScoreAnswersScore(Id caseId, String scoreAnswerMode) {
        Integer scoreIncrement = 0;
        for(Audit_Responses__c auditResObj : auditResList) {
           
            // Check for autofail question 
            if(auditResObj.Case__c == caseId && 
               autoFailQuestionSet.contains(String.valueOf(auditResObj.Audit_Question__c)) &&
               String.valueOf(auditResObj.Audit_Answer__c).equalsIgnoreCase('No')){
                isAutoFailed = true;
            }else if(auditResObj.Case__c == caseId && 
                scoreAnswerMode.equalsIgnoreCase(auditResObj.Audit_Answer__c)) {
                if(null != questionsMap.get(auditResObj.Audit_Question__c)) {
                    scoreIncrement += questionsMap.get(auditResObj.Audit_Question__c);
                }  
            }   
        }
        if(isAutoFailed){
           return 0;
        }else{
           return scoreIncrement;
        }
        
    }
    
    //Method used to get the Audit responses
    public List<Audit_Responses__c> getAuditResponses(Set<Id> caseIdSet) {
        return [Select Case__c, Audit_Answer__c, Audit_Question__c 
            from Audit_Responses__c Where Case__c IN :caseIdSet order by Case__c ];
    }
    
    //Method used to get the Cases
    public Map<Id,Case> getCases(Set<Id> caseIdSet) {
        Map<Id, Case> caseMapLoc = new Map<Id, Case>();
        for(Case caseObj : [Select Id, Possible_Score__c, Audit_Score__c, Status from 
            Case Where Id IN :caseIdSet order by Id]) {
            caseMapLoc.put(caseObj.Id, caseObj);        
        }
        return caseMapLoc;
    }
    
    //method used to cache the audit questions
    public Map<String, Integer> getAuditQuestionsScore() {
        if(null == questionsMap) {
            questionsMap = new Map<String, Integer>();
            for(Audit_Question__c auditQuestion :
                [Select Id,Question__c,Score__c,Auto_Fail__c from Audit_Question__c Order by Question__c Asc]) {
                if(String.valueOf(auditQuestion.Auto_Fail__c).equalsIgnoreCase('Yes')){
                   autoFailQuestionSet.add(auditQuestion.Question__c);
                }
                questionsMap.put(String.valueOf(auditQuestion.Question__c), 
                    Integer.valueOf(auditQuestion.Score__c));
            }
        }
        return questionsMap;
    }
    
    
}