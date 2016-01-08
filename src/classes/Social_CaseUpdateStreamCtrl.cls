public class Social_CaseUpdateStreamCtrl{
    public List<Case> caseList{get;set;} 
    public Map<id,Case> caseMap = null;
    public List<Case> casecontactList{get;set;}      
    public id sid;
    public integer intRows{get;set;}
    public String itemId{get;set;}
    public static set<id> caseId = new set<id>();
    public boolean showMore{get;set;}
    public boolean renderValue{get;set;}
    public Double DNRTimeExp{get;set;}
    public boolean showCaseReference{get;set;}
    public String strPostId{get;set;}
    public Social_CaseUpdateStreamCtrl(ApexPages.StandardController stdController) {
        intRows = 5;
        DNRTimeExp=Decimal.valueOf(label.Do_Not_Reassign_Time_Limit)/86400000;
        runCasesStream();
        showCaseReference = false;
        if(ApexPages.currentPage().getParameters().get('url')!=null && !ApexPages.currentPage().getParameters().get('url').equals('') && ApexPages.currentPage().getParameters().get('url').contains('postId=')){
            strPostId = ApexPages.currentPage().getParameters().get('url');
            String strSocialPostId = strPostId.subString(strPostId.IndexOf('postId=')+7, strPostId.length());
            strPostId  = strSocialPostId ;
            if(strSocialPostId!=null && !strSocialPostId.equals('')){
                Case c = [Select c.Social_CaseThreadID__c,Contact.Name From Case c where c.id in (Select parentId from SocialPost where id=: strSocialPostId)];
                if(c.Social_CaseThreadID__c!=null && !(c.Social_CaseThreadID__c).equals('')){
                    showCaseReference = true;
                    String referenceNumber = c.Social_CaseThreadID__c;
                    String contactName = c.Contact.Name;
                    if(referenceNumber != Null && contactName != Null) {
                        if(contactName.length() <= 5) {
                            strPostId = referenceNumber.substring(16,26)+'-'+contactName;
                        } else {
                            strPostId = referenceNumber.substring(16,26)+'-'+contactName.substring(0,5);
                        }
                    }
                }
            }
        }
    }    
    
    public List<Case> getCases(){
        caselist = new List<Case>();
        sid  = UserInfo.getUserId();
        for(Case cs:[Select id, casenumber,ownerid, lastmodifiedbyid, status, readunreadformula__c from case limit 10]){
            caselist.add(cs);
        }
        return caseList;
    }
    
    public PageReference runCasesStream() {
        caseMap = new  Map<id,Case>();
        caselist = new List<Case>();
        casecontactList = new List<Case>();
        sid  = UserInfo.getUserId();
        //for(Case cs : [Select id, Update_Reason__c, casenumber,ownerid, Social_CaseThreadID__c, Social_Persona_Name__c, Social_Care_Handle_Name__c, contactId, Contact.name, lastmodifieddate, Contact.lastmodifieddate, Contact.AccountId, Contact.lastmodifiedbyId, Social_Media_Source__c, lastmodifiedbyid, status, readunreadformula__c, priority from case where ReadUnreadCheck__c = TRUE and ownerId =:sid and lastmodifiedbyid != :sid and status <> 'Closed' order by lastmodifieddate ASC]){
          
        List<Case> tempCaseList = [Select id, Update_Reason__c,Do_Not_Reassign__c,Timer_Expires_AT__c,DNR_End_Time__c,Customer_Response_Received__c, readunreadcheck__c, casenumber, ownerid, Social_CaseThreadID__c, Social_Persona_Name__c, Social_Care_Handle_Name__c, contactId, Contact.name, lastmodifieddate, Contact.lastmodifieddate, Contact.AccountId, Contact.lastmodifiedbyId, Social_Media_Source__c, lastmodifiedbyid, status, readunreadformula__c, priority from case where ownerId =:sid and status <> 'Closed' and status <> 'Auto Closed' order by lastmodifieddate ASC limit 100];
        if(tempCaseList!=null && tempCaseList.size()>0){
            for(Case cs: tempCaseList){
                if(cs.DNR_End_Time__c!=null && cs.DNR_End_Time__c.gettime()-system.now().gettime()<integer.valueOf(label.Do_Not_Reassign_Time_Limit) && cs.DNR_End_Time__c.gettime()-system.now().gettime() >0 && cs.Do_Not_Reassign__c ){
                    caseMap.put(cs.id, cs);
                    caselist.add(cs);
                }
                else if(cs.lastmodifiedbyid == sid && cs.Update_Reason__c!=null &&  ((cs.Update_Reason__c).equals('Availability Assignment') || (cs.Update_Reason__c).equals('Self Assigned')) && cs.ReadUnreadCheck__c == TRUE ){
                    caseMap.put(cs.id, cs);
                    caselist.add(cs);
                }
                else if(cs.lastmodifiedbyid != sid && cs.Update_Reason__c!=null &&  !(cs.Update_Reason__c).equals('Availability Assignment') && cs.ReadUnreadCheck__c  == TRUE){
                    caseMap.put(cs.id, cs);
                    caselist.add(cs);
                }
                else if(cs.Update_Reason__c!=null &&  (cs.Update_Reason__c).equals('Round Robin') && cs.readunreadcheck__c == TRUE){
                    caseMap.put(cs.id, cs);
                    caselist.add(cs);
                }
            }
        }
        if(caselist!=null && caselist.size() > 5){
            showMore = true;
        }
        return null;
    }

    public PageReference getCount(){
        intRows = caseList.size();
        showMore =false;
        return null;
    }

    public PageReference markCaseRead() {
        Social_CaseUpdateStreamCtrl.caseId.add(itemId);
        caseMap.get(itemId).ReadUnreadCheck__c = false;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        update caseMap.get(itemId);
        //ReadUnreadCheck__c = false;
        PageReference markCaseRead = new PageReference('/'+itemId);
        return markCaseRead;
        
    }
}