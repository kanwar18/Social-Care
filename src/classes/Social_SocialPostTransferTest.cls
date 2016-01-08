/**************************************************************************
Class Name: Social_SocialPostTransferTest
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Test class for Social_SocialPostTransfer
Version History: Haemen Shah (8/19/2014)
****************************************************************************/
@isTest(SeeAllData=false)
public class Social_SocialPostTransferTest{
    Public static String contactIdString = System.Label.ContactIds;
    Public static list<String> contactIdSet = new list<String>();
    
    static testMethod void Social_SocialPostTransferTestA(){
        test.startTest();
            case caseObj = new case();
            caseObj.status='closed';
            caseObj.Resolution__c='Complete';
            caseObj.Component_Primary__c='DSL';
            caseObj.Component_Secondary__c = 'Availability - Dish / Direct TV / Satellite';
            caseobj.Component_Tertiary__c='Account Management';
            caseObj.Component_Quaternary__c='Disconnect / No Call Back';
            caseObj.Customer_Type__c='Consumer';
            caseObj.Root_Cause__c='Service performance';
            caseObj.Billing_Account_Number__c='abc';
            caseObj.Effort__c='High';
            caseObj.Reason='No Response';
            caseObj.Case_PostTag__c='dsl';
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            insert caseObj;
            
            contactIdSet.addAll(contactIdString.split(','));
           
            SocialPost socialPostObj = new SocialPost();
            socialPostObj.MediaProvider = 'Twitter';
            socialPostObj.parentId = caseObj.Id;
            if (!contactIdSet.isEmpty()) {
                socialPostObj.WhoId = contactIdSet[0];
            }
            socialPostObj.R6Service__IsOutbound__c = true;
            socialPostObj.Name = 'Post from ATT_TestBSC1';
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert socialPostObj;
            
            Social_SocialPostTransfer sopos = new Social_SocialPostTransfer();
            sopos.query = 'select id from case where status =: caseStatusClosed';
            database.executeBatch(sopos,200);
        test.stopTest();
    }
    
    static testMethod void Social_SocialPostTransferTestA1(){
        Social_SocialPostTransferScheduler p= new Social_SocialPostTransferScheduler();
        String sch = '0 0 8 13 2 ?';
        system.schedule('One Time Pro', sch, p);
    }
    
    static testMethod void Social_SocialPostTransferTestA2(){
        test.startTest();
            case caseObj = new case();
            caseObj.status='closed';
            caseObj.Resolution__c='Complete';
            caseObj.Component_Primary__c='DSL';
            caseObj.Component_Secondary__c = 'Availability - Dish / Direct TV / Satellite';
            caseobj.Component_Tertiary__c='Account Management';
            caseObj.Component_Quaternary__c='Disconnect / No Call Back';
            caseObj.Customer_Type__c='Consumer';
            caseObj.Root_Cause__c='Service performance';
            caseObj.Billing_Account_Number__c='abc';
            caseObj.Effort__c='High';
            caseObj.Reason='No Response';
            caseObj.Case_PostTag__c='dsl';
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            insert caseObj;
            
            contactIdSet.addAll(contactIdString.split(','));
           
            SocialPost socialPostObj = new SocialPost();
            socialPostObj.MediaProvider = 'FaceBook';
            socialPostObj.parentId = caseObj.Id;
            if (!contactIdSet.isEmpty()) {
                socialPostObj.WhoId = contactIdSet[1];
            }
            socialPostObj.R6Service__IsOutbound__c = true;
            socialPostObj.Name = 'Post from ATT_TestBSC1';
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert socialPostObj;
            
            Social_SocialPostTransfer sopos = new Social_SocialPostTransfer();
            sopos.query = 'select id from case where status =: caseStatusClosed';
            database.executeBatch(sopos,200);
        test.stopTest();
    }
}