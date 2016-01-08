trigger Social_caseEmailValidator on EmailMessage (before insert, before update){
  
    // Local Variables
    List<EmailMessage> emailAddressList = Trigger.new;
     Map<Id,EmailMessage> caseEmailMap = new Map<Id,EmailMessage>(); 
     List<EmailMessage> emailList = new List<EmailMessage>();
    // Trigger User Context
    User contextUser = [Select u.Id, u.Email From User u where u.Id=:Userinfo.getUserId() limit 1];
  
    // Check For Logged In User Email
    for(EmailMessage caseMail: emailAddressList){
        if(caseMail.FromAddress!=null && contextUser.Email!=null && String.valueof(caseMail.FromAddress).equalsIgnoreCase(contextUser.Email)){
            caseMail.adderror('Corporate Email Cannot Be Used As "From" Address. Please Use Team Email Address For Reply.');
        }
    }

    //Track Inbound emails and updates to existing case emails
    Map<Id, String> caseMap =  new Map<Id, String>();    
    for(EmailMessage em : Trigger.New){
        if(Trigger.isInsert){
            caseMap.put(em.ParentId, 'Insert');
            caseEmailMap.put(em.ParentId,em);
            emailList.add(em);
        }
        if(Trigger.isUpdate){
            caseMap.put(em.ParentId, 'Update');
        }
    }
    
    // Ashween updated for ITS1731, included caseEmailMap
    
    if(caseMap!=null && !caseMap.isEmpty() && caseEmailMap.size()>0){
        SocialStreamingAPIUpdate.caseEmailInsertUpdate(caseMap,caseEmailMap);
        if(Boolean.valueOf(Label.ACTIVATE_TIMER_APP)) {
            TimeTrackHandler.updateTimerRecords(caseMap.keySet(), 'Case Email ' + (Trigger.isInsert ? 'Insert' : 'Update')); 
        }
    }
    if(caseEmailMap.size()>0){    
        Social_CreateNewCase.renewClosedCase(caseEmailMap,emailList);
        //Social_ClosedCaseReOpenHandler.checkSecondSLA(caseEmailMap);
    }
}