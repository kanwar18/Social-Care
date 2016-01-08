public class Social_caseTeamUtilHandler 
{
  // Local Variables
  CaseTeamRole caseRole = new CaseTeamRole();
  List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
  Map<Id,Set<Id>> caseIdteamListMap = new Map<Id,Set<Id>>();
 
  // Define Constructor
  public Social_caseTeamUtilHandler(List<Id> caseIdList){
  	
  	if(!caseIdList.isEmpty()){
  		
  		// Query All Related Case Team Members
  		List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
  		caseTeamList = [Select c.TeamRoleId, c.ParentId, c.MemberId, c.Id From CaseTeamMember c where 
  		                c.ParentId IN: caseIdList];
  		                
  		// Construct The Map
  		for(CaseTeamMember teamMember: caseTeamList){
  			
  			if(caseIdteamListMap.containsKey(teamMember.ParentId)){
  				Set<Id> existSet = caseIdteamListMap.get(teamMember.ParentId);
  				existSet.add(teamMember.MemberId);
  				caseIdteamListMap.put(teamMember.ParentId, existSet);
  			}
  			else{
  				Set<Id> newSet = new Set<Id>();
  				newSet.add(teamMember.MemberId);
  				caseIdteamListMap.put(teamMember.ParentId, newSet);
  			}
  		}
  		
  		// Query The Required Case Team Role
  		caseRole = [Select c.Name, c.Id, c.AccessLevel From CaseTeamRole c limit 1];
  	}
  }
  
  // Method To Add Case Team Members
  public void addCaseTeamMember(Id CaseId, Id UserId){
  	
  	// Check If User Already Part Of Sales Team
  	Set<Id> existingCaseTeamIdSet = new Set<Id>();
  	existingCaseTeamIdSet = caseIdteamListMap.get(CaseId);
  	
  	if(existingCaseTeamIdSet==null || (!existingCaseTeamIdSet.isEmpty() && !existingCaseTeamIdSet.contains(UserId))){
  		CaseTeamMember newMember = new CaseTeamMember();
   		newMember.TeamRoleId = caseRole.Id;
   		newMember.ParentId = CaseId;
   		newMember.MemberId = UserId;
   		caseTeamList.add(newMember);
  	}
  }
  
  // Method To Insert Case Team Members
  public void insertCaseTeamDetails()
  {  
  	if(!caseTeamList.isEmpty()){
  		try{
  			insert caseTeamList;
  		}
  		catch(Exception Exp){
  			System.debug('EXCEPTION WHILE CASE TEAM INSERT' + Exp.getmessage());
  		}
  	}
  }
}