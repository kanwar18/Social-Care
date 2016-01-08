/********************************************************************************************************
*    Author :     Arun Ramachandran
*    Requirement: Reassignment of Cases and SLA's when Care Managers/Senior Ops Manager go on vacation
*                 or get promoted
*    Version:     1.0    
*    Created Date: 19th August 2013    
*********************************************************************************************************/

trigger SocialCaseReassignment on User (after update) {

    Set<Id> userListVacationBusiness = new Set<Id>(); // Set of Business User Id's who marked themselves on Vacation.
    Set<Id> userListPromotionBusiness = new Set<Id>();// Set of Business User Id's who have been promoted.    
    Boolean flag = true;
    Map<Id, List<Case>> businessCaseMap = new Map<Id, List<Case>>();
    Set<Id> userAvailableSet = new Set<Id>();
    
    for(User singleUser: Trigger.new){
        if(singleUser.IsActive == TRUE && singleUser.Availability__c == 'Vacation' && trigger.oldMap.get(singleUser.Id).Availability__c != singleUser.Availability__c){
            if(singleUser.ProfileId == System.label.CAREMANAGER_BUSINESS || singleUser.ProfileId == System.label.SENIOROPS_BUSINESS){
                userListVacationBusiness.add(singleUser.Id);
            }            
        }
        else if(singleUser.IsActive == TRUE && (trigger.oldMap.get(singleUser.Id).ProfileId) != singleUser.ProfileId){
                if((trigger.oldMap.get(singleUser.Id).ProfileId == System.label.CAREMANAGER_BUSINESS && singleUser.ProfileId == System.label.SENIOROPS_BUSINESS) || (trigger.oldMap.get(singleUser.Id).ProfileId == System.label.SENIOROPS_BUSINESS && singleUser.ProfileId != System.label.SENIOROPS_BUSINESS)){
                    userListPromotionBusiness.add(singleUser.Id);
                }               
        }
        if(singleUser.IsActive == TRUE && singleUser.Availability__c == 'Available' && trigger.oldMap.get(singleUser.Id).Availability__c != singleUser.Availability__c && singleUser.ProfileId == System.label.CAREMANAGER_BUSINESS){
            userAvailableSet.add(singleUser.Id);            
        }
        
    }
    if(userListVacationBusiness.size()>0){
        Social_CaseReassignment.reAssignOnVacationBusiness(userListVacationBusiness);
    }
    if(userListPromotionBusiness.size()>0){
        Social_CaseReassignment.reAssignOnPromotionBusiness(userListPromotionBusiness);
    }
    if(userAvailableSet.size()>0){
        system.debug('HIIIIIIIIIIIIIIII');
        Social_BusinessRoundRobin.businessCaseAssignmentAvailability(userAvailableSet);
    }
    
}