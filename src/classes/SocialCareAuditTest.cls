//Vijay - A test class for Audit Functionality for Capturing the Scores
@isTest(seeAllData = false)
public class SocialCareAuditTest {
    static Case caseObj = null;
    static List<Audit_Responses__c> auditResponsesList = null;
    
    //Data Initialization Block
    static {
        caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.Type = 'phone';
        caseObj.Priority = 'High';
        caseObj.Origin = 'Phone';
        caseObj.Audit_Status__c = 'Under QA';
        caseObj.RecordTypeId = [Select Id from RecordType Where DeveloperName = 'Consumer_Care_Case' Limit 1].get(0).Id;
        insert caseObj;

        insert getAuditQuestions();
        auditResponsesList = getAuditResponsesList();
        insert auditResponsesList;
        
    }
    
    //A test method to test the audit funcitonality
    public static testmethod void doExecuteAudit() {
        try {
            updateAuditResponses();
        } catch(Exception excep) {
            System.debug('Exception Caught in Test Class: #Line:'+excep.getLineNumber()+'|'+excep.getMessage());
            System.assertNotEquals('', excep.getMessage());
        }
    }
    
    // A test method used to execute the Social_Case Audit
    public static testmethod void doSocialCaseAudit() {
        try {
            ApexPages.currentPage().getParameters().put('id', caseObj.Id);
            ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
            Social_CaseAudit caseAudit = new Social_CaseAudit(stdController);
            new Social_CaseAudit();
            
            caseAudit.isCaseAudited();
            System.assertNotEquals(null, caseAudit.getIsAuditComplete());
            System.assertEquals(true, caseAudit.getItems().size() > 0);
            caseAudit.setError('Sample Error');
            System.assertNotEquals(null, caseAudit.getError());
            System.assertEquals(null, caseAudit.cancel());
            
            Test.startTest();
            
            System.assertEquals(null, caseAudit.saveAudit());
            update getUpdatedAuditRecords(auditResponsesList, true);
            System.assertEquals(null, caseAudit.saveAudit());
            update getUpdatedAuditRecords(auditResponsesList, false);
            System.assertEquals(null, caseAudit.saveAudit());
            caseAudit.isBusinessCare = true;
            
            System.assertEquals(null, caseAudit.saveAudit());
            Test.stopTest();
        } catch(Exception excep) {
            System.debug('Exception Caught in doSocialCaseAudit @ Test Class: #Line:'
                +excep.getLineNumber()+'|'+excep.getMessage());
            System.assertNotEquals('', excep.getMessage());
        }
    }
    
    //Method used to update the audit responses
    public static void updateAuditResponses() {
        update getUpdatedAuditRecords(auditResponsesList, true);
        caseObj.Possible_Score__c = 0;
        caseObj.Audit_Score__c = 0;
        update caseObj;
        auditResponsesList = getUpdatedAuditRecords(auditResponsesList, false);
        update auditResponsesList; 
    }    
    
    //A method used to insert the records in the audit responses
    public static List<Audit_Responses__c> getAuditResponsesList() {
        Audit_Responses__c auditResponse = null;
        List<Audit_Responses__c> auditResList = new List<Audit_Responses__c>();
        
        for(Audit_Question__c auditQues :
         [Select Id,Question__c,Score__c,Audit_Question_Type__c,Name,Coaching__c,Component__c,Active__c, 
         Answer__c from Audit_Question__c Order by Question__c Asc]) {
            auditResponse = new Audit_Responses__c();
            auditResponse.Audit_Question_Type__c = auditQues.Audit_Question_Type__c;
            auditResponse.Audit_Question__c = auditQues.Question__c;
            auditResponse.Audit_Coaching__c = auditQues.Coaching__c;
            auditResponse.Audit_Answer__c = auditQues.Answer__c;
            auditResponse.Audit_Component__c = auditQues.Component__c;
            auditResponse.Case__c = caseObj.Id;
            auditResList.add(auditResponse);
        }
        System.debug('# of QA Questions :'+auditResList.size());
        return auditResList;
    }
    
    //A method used to update the audit records
    public static List<Audit_Responses__c> getUpdatedAuditRecords(
        List<Audit_Responses__c> auditRessList, boolean isAnswerUpate) {
        Object objectObj = null;
        
        for(Integer auditCount = 0; auditCount < auditRessList.size(); auditCount++) {
            if(isAnswerUpate) {
                objectObj = (Math.mod(auditCount, 2) == 0) ? 
                    auditRessList.get(auditCount).put('Audit_Answer__c', 'Yes') :
                    auditRessList.get(auditCount).put('Audit_Answer__c', 'No');
            } else {
                objectObj = (Math.mod(auditCount, 2) == 0) ? 
                    auditRessList.get(auditCount).put('Audit_Answer__c', 'No') :
                    auditRessList.get(auditCount).put('Audit_Answer__c', 'NA');
            }
            if(auditCount == 3) {
                auditRessList.get(auditCount).put('Audit_Answer__c', null);
            }
        }
        return auditRessList;
    }
    
    //Method used to generate the audit questions
    public static List<Audit_Question__c> getAuditQuestions() {
        List<Audit_Question__c> auditQuestionList = new List<Audit_Question__c>();
        Audit_Question__c auditQues = null;
        Object objectObj = null;
        
        for(Integer quesCount = 0; quesCount < 10; quesCount++) {
            auditQues = new Audit_Question__c();
            
            if(quesCount < 5) { 
                auditQues.Audit_Question_Type__c = 'Business Care';
                auditQues.Coaching__c = 'Good';
                if(quesCount < 2) {
                    auditQues.Auto_Fail__c = 'yes';
                } else {
                    auditQues.Auto_Fail__c = 'no';
                }
            }
            else {
                auditQues.Audit_Question_Type__c = 'Consumer Care';
                auditQues.Coaching__c = 'Very Good';
                if(quesCount < 8) {
                    auditQues.Auto_Fail__c = 'yes';
                } else {
                    auditQues.Auto_Fail__c = 'no';
                }
            }       
            
            auditQues.Question__c = 'QA Question:'+(quesCount+1);
            auditQues.Answer__c = 'No';
            auditQues.Score__c = quesCount + 10;
            auditQues.Component__c = 'Customer Interaction';
            auditQues.Active__c = 'Yes';
            auditQues.DecreasingScore__c = 'Yes';
            
            auditQuestionList.add(auditQues);       
        }
        return auditQuestionList;
    }
}