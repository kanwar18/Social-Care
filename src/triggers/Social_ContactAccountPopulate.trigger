trigger Social_ContactAccountPopulate on Contact (before insert, before update, before delete){ 
  if (Boolean.valueOf(Label.DNE_Functionality) && Social_StreamingUtil.doNtFireEmail2CaseRun) {
      List<Contact> lcontact=new list<Contact>();//This list is used to store all the contacts updated.
      List<case> caseList = new List<case>();
      List<PermissionSetAssignment> scrubUserList = new List<PermissionSetAssignment>();
      set<id> setId = new set<id>(); 
      
      if(Trigger.isDelete){
          scrubUserList =[select PermissionSetId,AssigneeId from PermissionSetAssignment where PermissionSetId =: String.valueOf(label.ScrubTeamId) AND AssigneeId =: String.valueOf(UserInfo.getUserId())];
          If(scrubUserList.isEmpty()){
              for(Contact oldContact: Trigger.old){
                  String strLoggedInUserProfileId = (String.valueOf(UserInfo.getProfileId())).subString(0, 15);
                  System.debug('User Profile Id 15 digit Id: '+UserInfo.getProfileId());
                  String strNoContactDeletePermissionProfileIds = String.ValueOf(System.label.NoContactDeletePermissionProfileIds);
                      if(strNoContactDeletePermissionProfileIds!=null && strNoContactDeletePermissionProfileIds.contains(strLoggedInUserProfileId)){
                          oldContact.addError('You do not have the sufficient privilege to delete this record. Please contact your System Administrator');
                      }    
              }
         }
      }
      
        if(trigger.IsInsert){
            /*
            // Query Account For Radian6 Account
            Account[] radianAccount = [Select a.Name, a.Id From Account a where a.Name='Radian-6 Account' limit 1];
           
            // Check Contact For Empty
            for(Contact caseContact: Trigger.new){
                if(caseContact.AccountId==null && radianAccount.size()>0){
                    
                    // Update Contact
                    caseContact.AccountId = radianAccount[0].Id;
                }
            }
            */
        }
       /****************
       *
       * To update the related case that the contact has been updated for the Streaming API on Home page
       *
       *****************/
       
       if(trigger.IsUpdate){
           for(Contact sCont : trigger.new){
            if(!Social_StreamingUtil.contactProcessed.contains(sCont.Id)){
            setId.add(sCont.id);
            if(!string.isblank(sCont.Email)){
             sCont.Last_email_used__C=sCont.Email;
                 if(!string.isblank(sCont.all_contact_emails__c)){
                     if(!sCont.all_contact_emails__c.contains(sCont.Email)){
                         sCont.all_contact_emails__c=sCont.all_contact_emails__c+';'+sCont.Email;
                 }}
                     else
                     {
                         sCont.all_contact_emails__c=sCont.Email;
                     }
             lcontact.add(sCont);
            }
            }
        }
           if(setId.size() > 0){
                for(case cs : [select id, ReadUnreadCheck__c, ownerId, Status from case c where c.contactid IN: setId and c.status <> 'Closed' and c.status <> 'Auto Closed' ]){
                  if(Userinfo.getUserId()!=null && cs.OwnerId!=null && !Userinfo.getUserId().equals(cs.OwnerId)){
                  // Set DML Option
                    Database.DMLOptions dmo = new Database.DMLOptions();
                  dmo.assignmentRuleHeader.useDefaultRule = false;
                  
                    cs.ReadUnreadCheck__c = TRUE;
                    cs.Update_Reason__c = 'Contact Update';
                    
                    // Update Case Stage/Set Assignment Option
                    cs.setOptions(dmo);
                    
                    caseList.add(cs);
                    Social_CaseUpdateStreamCtrl.caseId.add(cs.Id);
                    }
                    else if(Userinfo.getUserId()!=null && cs.OwnerId!=null && Userinfo.getUserId().equals(cs.OwnerId)){
                        if(cs.ReadUnreadCheck__c){
                            cs.ReadUnreadCheck__c = FALSE;
                            caseList.add(cs);
                         Social_CaseUpdateStreamCtrl.caseId.add(cs.Id);
                            
                        }
                    }
    
                }
                if(caseList.size() > 0){
                    database.update(caseList, false);
                }
           }
       }  
   }
}