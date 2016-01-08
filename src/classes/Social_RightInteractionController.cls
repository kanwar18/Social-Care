public class Social_RightInteractionController{
    List<Quick_Links__c> quickLinksList{get;set;}
    List<ATT_Deals__c> attdealsList{get;set;}
    public string tosearch{set;get;}
    public string tosearchAttDeal{set;get;}
    Public boolean displayOutputPanel{get;set;}
    Public Boolean displayWarningMsg{get;set;}
    Public String showHideAll{get;set;}
    Public String showHideMyLinks {get;set;}
    Public String showHideAllDeals{get;set;}
    Public String showHideMyDeals{get;set;}
    Public String errMsg{get;set;}
    Public String UserId = UserInfo.getUserId();
    Public String ProfileId = UserInfo.getProfileId().substring(0,15);
    Profile UserProfile = [Select Name from Profile where id=:ProfileId limit 1];
    Public String ProfileName = UserProfile.Name;
    
    public Social_RightInteractionController(ApexPages.StandardController controller){
        tosearch = '';
        tosearchAttDeal = '';
        displayOutputPanel = false;
        displayWarningMsg = false;
        showHideAll = 'Show All';
        showHideMyLinks = 'My Links';
        showHideAllDeals = 'Show All';
        showHideMyDeals = 'My Deals';
        errMsg = '';
        quickLinksList = new List<Quick_Links__c>();
        attdealsList = new List<ATT_Deals__c>();
    }
    
    public List<Quick_Links__c> getQuickLinksList(){
        return quickLinksList;
    }
    
    Public void refreshLinkList() {
        showHideAll = 'Show All';
        showHideMyLinks = 'My Links';
        if (tosearch!= null && tosearch!= '') {
            displayOutputPanel = true;
            if(ProfileId!='' && ProfileId!=null && Label.SystemAdminProfileId.contains(ProfileId)){
                quickLinksList = [select name,Quick_Link__c,OwnerId from Quick_Links__c where name like :tosearch+'%' limit 20000];
            }
            else{
                quickLinksList = [select name,Quick_Link__c,OwnerId from Quick_Links__c where ((name like :tosearch+'%') AND (Owner_Profile_Id__c =:ProfileId OR Profile_Names__c INCLUDES (:ProfileName))) limit 20000];
            }
            if (!quickLinksList.isEmpty()) {
                displayOutputPanel = true;
                displayWarningMsg = false;
            } else {
                displayOutputPanel = false;
                errMsg = 'Search returned no results';
                displayWarningMsg = true;
            }
        } else {
            displayOutputPanel = false;
            displayWarningMsg = false;
        }
    } 
    Public void showAllRecords() {
        
        if (showHideAll.equalsIgnoreCase('Show All')) {
            
            showHideAll = 'Hide All';
            showHideMyLinks = 'My Links';
            if(ProfileId!='' && ProfileId!=null && Label.SystemAdminProfileId.contains(ProfileId)){
                quickLinksList = [select name,Quick_Link__c,OwnerId from Quick_Links__c limit 20000 ];
                 
            }
            else{
                quickLinksList = [select name,Quick_Link__c,OwnerId from Quick_Links__c WHERE (Owner_Profile_Id__c =:ProfileId OR Profile_Names__c INCLUDES (:ProfileName)) limit 20000 ];
                 
            }
            if (!quickLinksList.isEmpty()) {
                displayOutputPanel = true;
                displayWarningMsg = false;
            } else {
                displayOutputPanel = false;
                errMsg = 'Search returned no results'; //added on 0427 by Ashween
                displayWarningMsg = true;
                
            }
        } else if (showHideAll.equalsIgnoreCase('Hide All')) {
            showHideAll = 'Show All';
            quickLinksList.clear();
            displayOutputPanel = false;
            displayWarningMsg = false;
        }
    }
    
    Public void MyRecordsQuickLinks() {
        if (showHideMyLinks.equalsIgnoreCase('My Links')) {
            showHideMyLinks = 'Hide My Links';
            showHideAll = 'Show All';
            quickLinksList = [select name,Quick_Link__c,OwnerId from Quick_Links__c WHERE CreatedBy.id = :UserId limit 20000];
            if (!quickLinksList.isEmpty()) {
                displayOutputPanel = true;
                displayWarningMsg = false;
            } else {
                displayOutputPanel = false;
                errMsg = 'You have no Quick Links created by yourself';
                displayWarningMsg = true;
            }
        } else if (showHideMyLinks.equalsIgnoreCase('Hide My Links')) {
            showHideMyLinks= 'My Links';
            attdealsList.clear();
            displayOutputPanel = false;
            displayWarningMsg = false;
        }
    }
    
    Public void addNewLinks() {
        Set<String> userProfileIdList = new Set<String>();
        String profileIds = label.ATTDealProfileId;
        userProfileIdList.addAll(profileIds.split(','));
        if(userProfileIdList.Contains(userInfo.getProfileId())) {
            errMsg = '';
            displayWarningMsg = false;
        } else {
            displayWarningMsg = true;
            errMsg = 'You do not have sufficient privilage to create new Link.';
        }
    }
    
    //Logic for AttDeals
    
    public List<ATT_Deals__c> getattdealsList() {
        return attdealsList;
    }
    
    Public void refreshListAttDeal() {
        showHideAllDeals = 'Show All';
        showHideMyDeals = 'My Deals';
        if (tosearchAttDeal != null && tosearchAttDeal != '') {
            displayOutputPanel = true;
            if(ProfileId!='' && ProfileId!=null && Label.SystemAdminProfileId.contains(ProfileId)){
                attdealsList = [select name,link__c,OwnerId from ATT_Deals__c where name like :tosearchAttDeal+'%' limit 50000];
            }
            else{
                attdealsList = [select name,link__c,OwnerId from ATT_Deals__c where ((name like :tosearchAttDeal+'%') AND (Owner_Profile_Id__c =:ProfileId OR Profile_Names__c INCLUDES (:ProfileName))) limit 50000];
            }
            if (!attdealsList.isEmpty()) {
                displayOutputPanel = true;
                displayWarningMsg = false;
            } else {
                displayOutputPanel = false;
                errMsg = 'No ATT Deal Records Found.';
                displayWarningMsg = true;
            }
        } else {
            displayOutputPanel = false;
            displayWarningMsg = false;
        }
    }
    
    Public void showAllRecordsAttDeal() {     
        if (showHideAllDeals.equalsIgnoreCase('Show All')) {
            showHideAllDeals = 'Hide All';
            showHideMyDeals = 'My Deals';
            if(ProfileId!='' && ProfileId!=null && Label.SystemAdminProfileId.contains(ProfileId)){
                attdealsList = [select name,link__c,OwnerId from ATT_Deals__c limit 50000];
            }
            else{
                attdealsList = [select name,link__c,OwnerId from ATT_Deals__c where (Owner_Profile_Id__c =:ProfileId OR Profile_Names__c INCLUDES (:ProfileName)) limit 50000];
            }
            if (!attdealsList.isEmpty()) {
                displayOutputPanel = true;
                displayWarningMsg = false;
            } else {
                displayOutputPanel = false;
                displayWarningMsg = true;
            }
        } else if (showHideAllDeals.equalsIgnoreCase('Hide All')) {
            showHideAllDeals = 'Show All';
            attdealsList.clear();
            displayOutputPanel = false;
            displayWarningMsg = false;
        }
    }
    
    Public void MyRecordsAttDeal() {
        if (showHideMyDeals.equalsIgnoreCase('My Deals')) {
            showHideMyDeals= 'Hide My Deals';
            showHideAllDeals = 'Show All';
            attdealsList = [select name,link__c,OwnerId from ATT_Deals__c WHERE CreatedBy.id = :UserId limit 50000];            
            if (!attdealsList.isEmpty()) {
                displayOutputPanel = true;
                displayWarningMsg = false;
            } else {
                displayOutputPanel = false;
                errMsg = 'You have no Deals created by yourself';
                displayWarningMsg = true;
            }
        } else if (showHideMyDeals.equalsIgnoreCase('Hide My Deals')) {
            showHideMyDeals= 'My Deals';
            attdealsList.clear();
            displayOutputPanel = false;
            displayWarningMsg = false;
        }
    }
    
    
    Public void addNewDeals() {
        Set<String> userProfileIdList = new Set<String>();
        String profileIds = label.ATTDealProfileId;
        userProfileIdList.addAll(profileIds.split(','));
        if(userProfileIdList.Contains(userInfo.getProfileId())) {
            errMsg = '';
            displayWarningMsg = false;
        } else {
            displayWarningMsg = true;
            errMsg = 'You do not have sufficient privilage to create new deal.';
        }
    }  
    
    public boolean getIsVisible(){   

    boolean isVis;
    if(ProfileId!='' && ProfileId!=null && Label.BuisnessProfileIDs.contains(ProfileId)){
        isVis = false;
    }
    else{
         isVis = true;   
    }
    return isVis;
    }
}