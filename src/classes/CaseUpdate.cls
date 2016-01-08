/********************************
  Created Date: 12/07/13
  Author: Accenture
  Requirement: ITS-000149
  Version History: CaseUpdate
  Aug 15th 2013:ITS-000149: 
  Deployment Date: 23rd October 2013
  Version: ITS1641- Logic to flip record type to hs care rep
********************************/
public class CaseUpdate {

   public Case mCase{get; set;}
   public Case caseObj{get; set;}
   
   /*****Constructor**/       
        public CaseUpdate(ApexPages.StandardController controller){                     
            mCase =  (Case)controller.getRecord();
        }
        
        public void CaseVisibility(){
            try {
                caseObj =[Select Id, Update_Reason__c, ReadUnreadCheck__c, OwnerId  from Case where ID=:mCase.ID];
                if(caseObj.OwnerId!=null && UserInfo.getUserId().equals(caseObj.OwnerId) && caseObj.readunreadcheck__c) {
                    caseObj.readunreadcheck__c = false;
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    Social_StreamingUtil.doNotFireUpdateReason = false;
                    update caseObj;
                }
            } 
            catch(Exception excep) {
                System.debug('Exception Caught by CaseUpdate.caseVisibility():'+excep.getMessage());
            }
        }
}