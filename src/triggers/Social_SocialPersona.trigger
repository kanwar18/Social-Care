trigger Social_SocialPersona on SocialPersona (before insert, before update) {
    if (Social_StreamingUtil.doNotUpdatePersona) {
        //Track Social Persona Inserts/Updates on a Case
        Map<Id, String> caseMap =  new Map<Id, String>();
        for(SocialPersona sp : Trigger.new){
            if(Trigger.isInsert){
                caseMap.put(sp.ParentId, 'Insert');
            }
            if(Trigger.isUpdate){
                caseMap.put(sp.ParentId, 'Update');
            }

        }
        if(caseMap!=null && !caseMap.isEmpty()){
            SocialStreamingAPIUpdate.caseSocialPersonaInsertUpdate(caseMap);
        }
    }
}