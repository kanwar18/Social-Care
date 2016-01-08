/*
*                                                                                                 *
*                            Version 1.20                                                         *
*                                                                                                 *
* Creation Date: 04.Jun.2012                    Sameer N Miraj                                    *
* Last Modified: 7.Nov.2014                     Aditya                                            *
*                                                                                                 *
*                             © 2008 - Accenture - All Rights Reserved                            *

*/


public class VFC01_StringSearch {   
    //Variable to capture the user input string.
    public string yourString{get;set;}
    
    //Booleans to capture the input inthe checkboxes.
    public boolean isApexClass{get;set;}
    public boolean isApexTrigger{get;set;}
    public boolean isApexPage{get;set;}
    public boolean isEmailTemplate{get;set;}
    public boolean isProfile{get;set;}
    public boolean isApexComponent{get;set;}
    public boolean isSearchAll{get;set;}
    public boolean isGroup{get;set;}
    public boolean isPermissionSet{get;set;}
    public boolean isRole{get;set;}
    public boolean isReport{get;set;}
    public boolean isDashboard{get;set;}
    public boolean isStaticResource{get;set;}
    public boolean isSites{get;set;}
    public boolean isRecordType{get;set;}
    public boolean isDocument{get;set;}
    public boolean isAttachment{get;set;}
    public boolean isValidationRule{get;set;}
    public boolean isWorkflowRule{get;set;}
    public boolean isWorkflowFieldUpdate{get;set;}
    
    public boolean isObject{get;set;}    //SS
    public boolean isCustomSetting{get;set;}  //SS
    public boolean isCustomSettingField{get;set;}  //SS
    public boolean isField{get;set;}     //SS 
    
    //To capture the BaseURL, used to in the output link to open the class.
    public string baseURL{get;set;}
    Public boolean flag = false;
    
    //Static variables for web service
    Public static final String ERRORCONDITIONFORMULA = 'errorConditionFormula';
    Public static final String FULLNAME = 'FullName';
    Public static final String URLWEB = 'url';
    Public static final String FIELD = 'field';
    Public static final String WORKFLOWRULE = 'WorkflowRule';
    Public static final String FORMULA = 'formula';
    Public static final String BOOLEANFILTER = 'booleanFilter';
    Public static final String GET = 'GET';
    Public static final String CONTENT_TYPE = 'Content-type';
    Public static final String APPLICATION_JSON = 'application/json';
    Public static final String AUTHORIZATION = 'Authorization';
    Public static final String BEARER = 'Bearer '; // NEED TO HAVE A SPACE AFTER 

    public boolean getflag() {
        return flag;
    } 
    
    //to calculate the number of pages required to display for pagination.
    public integer pageNumber{get;set;}
    
    //variables for pagination.
    public List<INNER01_StringSearch> paginatedResults {get;set;}
    public List<selectOption> pageList {get;set;} 
    public integer paginationSize {get;set;}
    
    private List<INNER01_StringSearch> stringSearchList = new List<INNER01_StringSearch>() ;
    
    private boolean actionSubmit , nonEmptyRecord   ;
    
    //Variables added to search for file name
    public static final String APEX_CLASS = 'Apex Class';
    public static final String APEX_TRIGGER = 'Apex Trigger';
    public static final String VF_PAGE = 'Visualforce Page';
    public static final String APEX_COMPONENT = 'Visualforce Component';
    public static final String VALIDATION_RULE = 'Validation Rule';
    public static final String WORKFLOW_RULE = 'Workflow Rule';
    public static final String WORKFLOW_FIELDUPDATE = 'Workflow Field Update';
    
    public string searchRadioButton = 'FileData';
    
    // ============================================================================
    // = G.E.T.T.E.R.S
    // ============================================================================
    public String getSearchRadioButton(){
        return this.searchRadioButton;
    }
    
    public void setSearchRadioButton(String s){
        this.searchRadioButton = s;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('FileName','Search file name patterns')); 
        options.add(new SelectOption('FileData','Search containing text')); 
        return options; 
    }
    
    // ============================================================================
    // = C.O.N.S.T.R.U.C.T.O.R
    // ============================================================================
    public VFC01_StringSearch() {
        //default values 
        actionSubmit  = false ;
        nonEmptyRecord    = true ;
        paginationSize  = 10;
        getObjectNames();
    }
    
    public void onclickaction() {
        if('FileName'.equalsIgnoreCase(searchRadioButton))
            flag=true;
        else
            flag=false;
    }
    //Search() method is called when a user click on the Search button on the UI. 
    public PageReference search() {
        actionSubmit  = true ;
        nonEmptyRecord    = true ;
        pageNumber = 1; 
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        stringSearchList.clear();
        //Condition added to search for file name
        if('FileName'.equalsIgnoreCase(searchRadioButton)){
            searchFileName();
        }else{
            //Check if the String exists in all Apex classes.
            if(isApexClass){
                for(ApexClass apClass : [Select id, Name, body from ApexClass]) {
                    String comp = 'Apex Class';
                    if(apClass.body.contains(yourString)){
                         nonEmptyRecord  = false;
                         wordSearch(apClass.Name, comp, apClass.body, apClass.id,'apexClass');
                    }
                }
           }
           //Check if the String exists in all VF Pages.
           if(isApexPage){
               for(ApexPage apPage : [Select id, Name, markup from ApexPage]) {
                   String comp = 'Visualforce Page';
                   if(apPage.markup.contains(yourString)){
                       nonEmptyRecord  = false;
                       wordSearch(apPage.Name, comp, apPage.markup, apPage.id,'visualForcePage');
                   }
               }
          }
          //Check if the String exists in all Apex Triggers.
          if(isApexTrigger){
              for(ApexTrigger apTrigger : [Select id, Name, body from ApexTrigger]) {
                  String comp = 'Apex Trigger';
                  if(apTrigger.body.contains(yourString)){
                      nonEmptyRecord  = false;
                      wordSearch(apTrigger.Name, comp, apTrigger.body, apTrigger.id,'triggers');
                  }
              }
          }
          //Check if the String exists in Email Templates.
          if(isEmailTemplate){
              for(EmailTemplate emailTemp: [Select id, Name,body from EmailTemplate]) {
              System.debug('@@@@'+emailTemp);
                  String comp = 'Email Templates';
                  if(emailTemp.name.contains(yourString)){
                      nonEmptyRecord  = false;
                      if(emailTemp.body != null)
                      wordSearch(emailTemp.Name, comp , emailTemp.body, emailTemp.id,'Email Templates');
                  }
              }
          }
          //Check if the String exists in all Components.
          if(isApexComponent){
              for(ApexComponent apComponent : [Select id,Name, markup from ApexComponent]) {
                  String comp = 'Visualforce Component';
                      if(apComponent.markup.contains(yourString)){
                            nonEmptyRecord  = false;
                            wordSearch(apComponent.Name, comp, apComponent.markup, apComponent.id,'visualForceComponent');
                        }
                    }
            }
            //check if the string exists in validation rule
            if (isValidationRule) {
                try {
                    String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                    String url =  salesforceHost + '/services/data/v30.0/tooling/query/?q=Select+fullname+,metadata+from+ValidationRule';
                    HttpRequest req = new HttpRequest();
                    req.setMethod(GET);
                    req.setEndpoint(url);
                    req.setHeader(CONTENT_TYPE, APPLICATION_JSON);
                    req.setHeader(AUTHORIZATION, BEARER + UserInfo.getSessionId());
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    System.debug(res.getBody());
                    if (res.getStatusCode() == 200) {
                        String validationRuleName = '';//To store Validation rule Name
                        String objectName = '';//To store validation rule object name
                        String validationRuleCriteria = '';//To store validation rule criteria
                        String validationRuleId = '';// To store validation rule Id
                        JSONParser parser = JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            //Read Validation rule error condition
                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == ERRORCONDITIONFORMULA) {
                                parser.nextToken();
                                validationRuleCriteria = parser.getText();
                            //Read Name of validation rule
                            } else if (parser.getCurrentToken() == JSONToken.VALUE_STRING && parser.getCurrentName() == FULLNAME) {
                                if (parser.getText() != null) {
                                    validationRuleName = parser.getText().substringAfter('.');
                                    objectName =  parser.getText().substringBefore('.');
                                }
                            //Read Validation Rule ID 
                            } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == URLWEB) {
                                parser.nextValue();
                                validationRuleId = parser.getText();
                                validationRuleId = validationRuleId.substringAfterLast('/');
                            }                        
                            if (validationRuleCriteria != null && validationRuleCriteria != '' && validationRuleName != null && validationRuleName != '' && objectName != null && objectName != '' && validationRuleId != Null && validationRuleId != '') {
                                if (validationRuleCriteria.contains(yourString)) {
                                    String comp = 'Validation Rule : ' + objectName;
                                    nonEmptyRecord  = false;
                                    wordSearch(validationRuleName, comp,validationRuleCriteria , validationRuleId,'ValidationRule');
                                }
                                validationRuleId = '';
                                validationRuleCriteria = '';
                                validationRuleName = '';
                                objectName = '';
                            }
                        }
                    } else {
                        //condition in case Tooling API service fails
                    }
                } catch (Exception ex) {
                    system.debug('Error Occured' + ex.getMessage());
                }  
            }
            //Check if the string exists in Workflow rule
            if (isWorkflowRule) {
                try {
                    String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                    String url =  salesforceHost + '/services/data/v30.0/tooling/query/?q=Select+fullname+,metadata+from+WorkflowRule';
                    HttpRequest req = new HttpRequest();
                    req.setMethod(GET);
                    req.setEndpoint(url);
                    req.setHeader(CONTENT_TYPE, APPLICATION_JSON);
                    req.setHeader(AUTHORIZATION, BEARER + UserInfo.getSessionId());
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug(res.getBody());
                    if (res.getStatusCode() == 200) {
                        String workFlowRuleName = '';// To store workflow rule name
                        String workFlowObject = '';//To store workflow object name
                        String workFlowRuleCriteria = '';//To store workflow rule criteria
                        String workFlowRuleId = '';// To store workflow rule Id
                        JSONParser parser = JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            //Read Workflow rule name
                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == FULLNAME) {
                                parser.nextValue();
                                workFlowRuleName = parser.getText().substringAfter('.');
                                workFlowObject = parser.getText().substringBefore('.');
                            //Read Workflow rule criteria
                            } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == FIELD) {
                                parser.nextValue();
                                workFlowRuleCriteria = parser.getText().substringAfter('.');
                                //Get other filter criterias present in the workflow rule
                                While (parser.nextValue() != null) {
                                    if (parser.getCurrentName() == FIELD) {
                                        workFlowRuleCriteria += parser.getText().substringAfter('.');
                                    }
                                    //Break while loop once current work critieria is over
                                    else if (parser.getText() == WORKFLOWRULE) {
                                        break;
                                    }
                                }
                            //Read Workflow rule Id
                            } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == URLWEB) {
                                parser.nextValue();
                                workFlowRuleId = parser.getText();
                                workFlowRuleId = workFlowRuleId.substringAfterLast('/');
                            //Read Workflow formaula if present
                            } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == FORMULA) {
                                parser.nextValue();
                                workFlowRuleCriteria = parser.getText();
                            } 
                            //Read the data 
                            if (workFlowRuleName != null && workFlowRuleName != '' && workFlowObject != Null && workFlowObject != '' && workFlowRuleCriteria != Null && workFlowRuleCriteria != '' && workFlowRuleId != Null && workFlowRuleId != '') {
                                if (workFlowRuleCriteria.contains(yourString)) {
                                    String comp = 'Workflow Rule : ' + workFlowObject;
                                    nonEmptyRecord  = false;
                                    wordSearch(workFlowRuleName, comp,workFlowRuleCriteria , workFlowRuleId,'WorkflowRule');
                                }
                                workFlowRuleName = '';
                                workFlowObject = '';
                                workFlowRuleCriteria = '';
                                workFlowRuleId = '';
                            }
                        }
                    }
                } catch (Exception ex) {
                    system.debug(VFC01_GenericHighLighter.ERROR_STRING + ex.getMessage());
                }
            }
            //Search in Workflow Field updates
            if (isWorkflowFieldUpdate) {
                try {
                    String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                    String url =  salesforceHost + '/services/data/v32.0/tooling/query/?q=Select+FullName+,metadata+from+WorkflowFieldUpdate';
                    HttpRequest req = new HttpRequest();
                    req.setMethod(GET);
                    req.setEndpoint(url);
                    req.setHeader(CONTENT_TYPE, APPLICATION_JSON);
                    req.setHeader(AUTHORIZATION, BEARER + UserInfo.getSessionId());
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    //check result
                    if (res.getStatusCode() == 200) {
                        String workFlowFieldUpdateName = '';// To store workflow Field Update name
                        String workFlowFieldUpdateObject = '';//To store workflow Field Update object name
                        String workFlowFieldUpdate = '';//To store workflow Field Update
                        String workFlowFieldUpdateId = '';// To store workflow Field Update Id
                        JSONParser parser = JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            //Get Full Name of the workflow field update
                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == FULLNAME) {
                                parser.nextValue();
                                workFlowFieldUpdateName = parser.getText().substringAfter('.');
                                workFlowFieldUpdateObject = parser.getText().substringBefore('.');
                            //Get Id of Workflow field update
                            } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == URLWEB) {
                                parser.nextValue();
                                workFlowFieldUpdateId = parser.getText();
                                workFlowFieldUpdateId = workFlowFieldUpdateId.substringAfterLast('/');
                            //Get field present in workflow field update
                            } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == FIELD) {
                                parser.nextValue();
                                workFlowFieldUpdate = parser.getText();
                            }
                            if (workFlowFieldUpdateName != null && workFlowFieldUpdateName != '' && workFlowFieldUpdateId != null && workFlowFieldUpdateId != '' && workFlowFieldUpdate != null && workFlowFieldUpdate != '') {
                                if (workFlowFieldUpdate.contains(yourString)) {
                                    String comp = 'Workflow Field Update : ' + workFlowFieldUpdateObject;
                                    nonEmptyRecord  = false;
                                    wordSearch(workFlowFieldUpdateName, comp,workFlowFieldUpdate , workFlowFieldUpdateId,'WorkflowFieldUpdate');
                                }
                                workFlowFieldUpdate = '';
                                workFlowFieldUpdateId = '';
                                workFlowFieldUpdateObject = '';
                                workFlowFieldUpdateName = '';
                            }
                        }
                    }
                } catch (Exception ex) {
                    system.debug(VFC01_GenericHighLighter.ERROR_STRING + ex.getMessage());
                }
            }
        }
        loadPaginatedResults();
        return null;
     }

    
   public PageReference changePageSize(){
       pageNumber = 1 ;
       loadPaginatedResults();
       return null;
   }
    //When clicked on the Previous Page link on the UI, it points to the below method.  
    public pageReference previousPage(){
        pageNumber = pageNumber - 1;
        loadPaginatedResults();
        return null;
    } 
    
    //to check if the next page link has to enabled.
    public boolean getNextPageEnabled(){
        return (((pageNumber * paginationSize)  <= stringSearchList.size()) && stringSearchList.size() > paginationSize   ) ;
    }
    
    //to check if the Previous Page is enabled.
    public boolean getPreviousPageEnabled(){
        return ! (pageNumber == 1 );
    }
    
    //Method to get the total count of the pages to be displayed.   
    public Integer getTotalPageCount(){
        integer total_no_of_pages = stringSearchList.size()/paginationSize ;
        if(math.mod(stringSearchList.size(),paginationSize) > 0){
            total_no_of_pages = total_no_of_pages +1;
        }
        return total_no_of_pages;
    }
    
    //When clicked on the Next Page link on the UI, it points to the below method.  
    public pageReference nextPage(){
        pageNumber = pageNumber + 1;
        loadPaginatedResults();
        return null;
    } 
    
    public List<String> getPaginationBlockList() {
        List<String> stringList = new List<String>();
        stringList.add('1');
        return stringList; 
    }
   
    public boolean getNoResultsDisplayError() {
        return actionSubmit && nonEmptyRecord;  
    }
    
    public boolean getLoadResults() {
        return actionSubmit && (!nonEmptyRecord);  
    }
    
    //Below method splits the vode line by line and searched if the string exists in that line
    //and adds the entry in the stringSearchList which is of type the wrapper class, stringSearch.
    private void wordSearch(string entityName, String entity, String body, Id coId,String psedoColumnName) {
        List<String> eachLineCode = body.split('\n');
        if(eachLineCode.size()>0){
            integer count = 1;
            String lines = '';
            boolean isAvailable = false;
            for(string s : eachLineCode){
                if(s.contains(yourString)){
                    if(lines ==''){
                        lines = string.valueOf(count);
                    }else{
                        lines = lines + ', ' + string.valueOf(count);
                    }
                    isAvailable = true; 
                }
                count++;
            }
            if(isAvailable){
                stringSearchList.add(new INNER01_StringSearch(entityName, entity, lines, coId, body,psedoColumnName));
            }
        }
    }
     //Loads the paginated Results.
     private void loadPaginatedResults(){
        paginatedResults = new List<INNER01_StringSearch>();
        integer startIndex = (pageNumber - 1) * paginationSize ;
        integer endIndex  = pageNumber * paginationSize ;
        for(integer i= startIndex ; i < endIndex; i++){
            if (i < stringSearchList.size() ){
                paginatedResults.add(stringSearchList.get(i));
            } else {
                break;
            }
        }
        loadPageNumberDropDown();
    }
    
    private void loadPageNumberDropDown(){
        pageList = new list<selectOption>();
        for(integer i = 1; i<= getTotalPageCount() ; i++){
            pageList.add(new selectOption(''+i, ''+i));
        }
    }
    
    
    /**
    * Method to search for Class, Page, Trigger and Components based on the file name
    */
    private void searchFileName(){
        String searchString = '%' + yourString + '%';
        String ObjsearchString = yourString;
        if(isApexClass){
            for(ApexClass singleClass : [Select Id, Name from ApexClass where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleClass.Name, APEX_CLASS, '', singleClass.Id, '', APEX_CLASS));
                nonEmptyRecord  = false;
            }
        }
        if(isApexPage){
            for(ApexPage singlePage : [Select Id, Name from ApexPage where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singlePage.Name, VF_PAGE, '', singlePage.Id, '', VF_PAGE));
                nonEmptyRecord  = false;
            }
        }
        if(isApexTrigger){
            for(ApexTrigger singleTriggger : [Select Id, Name from ApexTrigger where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleTriggger.Name, APEX_TRIGGER, '', singleTriggger.Id, '', APEX_TRIGGER));
                nonEmptyRecord  = false;
            }
        }        
        if(isemailTemplate){
            for(emailTemplate singleemailTemplate :[Select Id, Name from emailTemplate where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleemailTemplate.Name, 'Email Template', '', singleemailTemplate.Id, '', 'Email Template'));
                nonEmptyRecord  = false;
            }
        }
        if(isReport){
            for(Report singleReport :[Select Id, Name from Report where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleReport.Name, 'Report', '', singleReport.Id, '', 'Report'));
                nonEmptyRecord  = false;
            }
        }
        if(isDashboard){
            for(Dashboard singleDashboard :[Select Id, DeveloperName from Dashboard where DeveloperName LIKE :searchString ORDER BY DeveloperName LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleDashboard.DeveloperName , 'Dashboard', '', singleDashboard.Id, '', 'Dashboard'));
                nonEmptyRecord  = false;
            }
        }       
        if(isApexComponent){
            for(ApexComponent singleComponent :[Select Id, Name from ApexComponent where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleComponent.Name, APEX_COMPONENT, '', singleComponent.Id, '', APEX_COMPONENT));
                nonEmptyRecord  = false;
            }
        }
        if(isProfile){
            for(Profile singleProfile :[Select Id,Name from Profile where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleProfile.Name , 'Profile', '', singleProfile.Id, '', 'Profile'));
                nonEmptyRecord  = false;
            }
        }
        if(isRole){
            for(UserRole singleRole :[Select Id,Name from UserRole where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleRole.Name , 'Role', '', singleRole.Id, '', 'Role'));
                nonEmptyRecord  = false;
            }
        }
        if(isGroup){
            for(Group singleGroup :[Select Id,Name from Group where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleGroup.Name , 'Group', '', singleGroup.Id, '', 'Group'));
                nonEmptyRecord  = false;
            }
        }
        if(isStaticResource){
            for(StaticResource singleStaticResource :[Select Id,Name from StaticResource where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleStaticResource.Name , 'Static Resource', '', singleStaticResource.Id, '', 'Static Resource'));
                nonEmptyRecord  = false;
            }
        }
        if(isSites){
            for(Site singleSite :[Select Id,Name from Site where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleSite.Name , 'Site', '', singleSite.Id, '', 'Site'));
                nonEmptyRecord  = false;
            }
        }
        if(isRecordType){
            for(RecordType singleRecordType :[Select Id,DeveloperName from RecordType where Name LIKE :searchString ORDER BY DeveloperName LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleRecordType.DeveloperName, 'RecordType', '', singleRecordType.Id, '', 'RecordType'));
                nonEmptyRecord  = false;
            }
        }
        if(isDocument){
            for(Document singleDocument :[Select Id,Name from Document where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleDocument.Name, 'Document', '', singleDocument.Id, '', 'Document'));
                nonEmptyRecord  = false;
            }
        }
        if(isAttachment){
            for(Attachment singleAttachment :[Select Id,Name from Attachment where Name LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singleAttachment.Name, 'Attachment', '', singleAttachment.Id, '', 'Attachment'));
                nonEmptyRecord  = false;
            }
        }
        if(isPermissionSet){
            for(PermissionSet singlePermissionSet :[Select Id,Label,Name from PermissionSet where Label LIKE :searchString ORDER BY Name LIMIT 10000]){
                stringSearchList.add(new INNER01_StringSearch(singlePermissionSet.Name, 'PermissionSet', '', singlePermissionSet.Id, '', 'PermissionSet'));
                nonEmptyRecord  = false;
            }
        }
        if(isObject){
          //  getObjectNames();
            for(String ObjName:mapNameLabel.keyset()){           
             String ObjectName_Prefix = mapNameLabel.get(ObjName);
             String ObjLabel = ObjectName_Prefix.split('-!-')[0];
             string PreFix = ObjectName_Prefix.split('-!-')[1];
             
             if(ObjLabel.toUpperCase().contains(ObjsearchString.toUpperCase())){
                stringSearchList.add(new INNER01_StringSearch(ObjLabel, 'Object', '',prefix , '', 'Object'));
                nonEmptyRecord  = false;
             }           
           }
        }
        if(isCustomSetting){
          // getObjectNames();
            for(String ObjName:mapCustomSettingNames.keyset()){           
             String ObjectName_Prefix = mapCustomSettingNames.get(ObjName);
             String ObjLabel = ObjectName_Prefix.split('-!-')[0];
             string PreFix = ObjectName_Prefix.split('-!-')[1];
             
             if(ObjLabel.toUpperCase().contains(ObjsearchString.toUpperCase())){
                stringSearchList.add(new INNER01_StringSearch(ObjLabel, 'Custom Setting', '',prefix , '', 'Custom Setting'));
                nonEmptyRecord  = false;
             }           
           }
        }
        if(isField){
           //getObjectNames();
           Map<string,string> mapObjFields ,mapCSObjFields;
           getObjectFields();
           for(string ObjName:mapNameLabel.keyset() ){
              mapObjFields = new map<string,string>();
              mapObjFields = mapObjectFields.get(ObjName);
               for(string FieldName:mapObjFields.keyset()) {
                   string Field_Obj_Label = mapObjFields.get(FieldName);
                   string FieldLabel = Field_Obj_Label.split('-!-')[0];
                   string ObjLabel =   Field_Obj_Label.split('-!-')[1];           
                   string Prefix =   Field_Obj_Label.split('-!-')[2];                           
                   if(FieldLabel.toUpperCase().contains(ObjsearchString.toUpperCase())){
                       stringSearchList.add(new INNER01_StringSearch(FieldLabel, 'Fields -(Object : '+ObjLabel +')', '',prefix , '', 'Fields'));
                       nonEmptyRecord  = false;
                   }               
               }                
           }
           for(string CSObjName:mapCustomSettingNames.keyset()){
               system.debug('---inside CS for1---');
               mapCSObjFields = new map<string,string>();
              mapCSObjFields = mapObjectFields.get(CSObjName);
               for(string FieldName:mapCSObjFields.keyset()) {
               system.debug('---inside CS for2---');
                 string Field_Obj_Label = mapCSObjFields.get(FieldName);
                 string FieldLabel = Field_Obj_Label.split('-!-')[0];
                 string ObjLabel =   Field_Obj_Label.split('-!-')[1];           
                 string Prefix =   Field_Obj_Label.split('-!-')[2];           
                 system.debug('---inside FieldLabel--'+FieldLabel +'--obj label--'+ObjLabel);
                  
                if(FieldLabel.toUpperCase().contains(ObjsearchString.toUpperCase())){
                                    system.debug('---inside CS if2---');
                   stringSearchList.add(new INNER01_StringSearch(FieldLabel, 'Custom Setting Fields -(CustomSetting : '+ObjLabel+' )', '',prefix , '', 'Fields'));
                   nonEmptyRecord  = false;
                 }               
              }     
          }
        }
        if (isValidationRule) {
            String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
            String url =  salesforceHost + '/services/data/v30.0/tooling/query/?q=Select+fullname+,metadata+from+ValidationRule';
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            if (res.getStatusCode() == 200) {
                //String to store validation rule name
                String validationRuleName = '';
                //String to store validation rule id
                String validationRuleId = '';
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    //Read Validation Rule Name
                    if (parser.getCurrentToken() == JSONToken.VALUE_STRING && parser.getCurrentName() == 'FullName') {
                        validationRuleName = parser.getText().substringAfter('.');
                    //Read Validation Rule Id
                    } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'url') {
                        parser.nextValue();
                        validationRuleId = parser.getText();
                        validationRuleId = validationRuleId.substringAfterLast('/');
                    }
                    //If all string are not null insert record
                    if (validationRuleName != null && validationRuleName != '' && validationRuleId != null && validationRuleId != '') {
                        if (validationRuleName.contains(yourString)) {
                            stringSearchList.add(new INNER01_StringSearch(validationRuleName, VALIDATION_RULE, '', validationRuleId, '', VALIDATION_RULE));
                            nonEmptyRecord  = false;
                        }
                        validationRuleName = '';
                        validationRuleId = '';
                    }
                }
            }
        }
        //Check if the string exists in Workflow rule
        if (isWorkflowRule) {
            String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
            String url =  salesforceHost + '/services/data/v30.0/tooling/query/?q=Select+fullname+,metadata+from+WorkflowRule';
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            if (res.getStatusCode() == 200) {
                String workFlowRuleName = '';// To store workflow rule name
                String workFlowRuleId = '';// To store workflow rule Id
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    //Read Workflow rule name
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'FullName') {
                            parser.nextValue();
                            workFlowRuleName = parser.getText().substringAfter('.');
                    } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'url') {
                            parser.nextValue();
                            workFlowRuleId = parser.getText();
                            workFlowRuleId = workFlowRuleId.substringAfterLast('/');
                    }
                    if (workFlowRuleName != null && workFlowRuleName != '' && workFlowRuleId != null && workFlowRuleId != '') {
                        if (workFlowRuleName.contains(yourString)) {
                            stringSearchList.add(new INNER01_StringSearch(workFlowRuleName, WORKFLOW_RULE, '', workFlowRuleId, '', WORKFLOW_RULE));
                            nonEmptyRecord  = false;
                        }
                        workFlowRuleName = '';
                        workFlowRuleId = '';
                    }
                }
            }
        }
        if (isWorkflowFieldUpdate) {
            String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
            String url =  salesforceHost + '/services/data/v32.0/tooling/query/?q=Select+FullName+,metadata+from+WorkflowFieldUpdate';
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            Http http = new Http();
            HTTPResponse res = http.send(req);
            //check result
            if (res.getStatusCode() == 200) {
                String workFlowFieldUpdateName = '';// To store workflow Field Update name
                String workFlowFieldUpdateId = '';// To store workflow Field Update Id
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    //Get Full Name of the workflow field update
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'FullName') {
                        parser.nextValue();
                        workFlowFieldUpdateName = parser.getText().substringAfter('.');
                    } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'url') {
                        parser.nextValue();
                        workFlowFieldUpdateId = parser.getText();
                        workFlowFieldUpdateId = workFlowFieldUpdateId.substringAfterLast('/');
                    }
                    if (workFlowFieldUpdateName != null && workFlowFieldUpdateName != '' && workFlowFieldUpdateId != null && workFlowFieldUpdateId != '') {
                        if (workFlowFieldUpdateName.contains(yourString)) {
                            stringSearchList.add(new INNER01_StringSearch(workFlowFieldUpdateName, WORKFLOW_FIELDUPDATE, '', workFlowFieldUpdateId, '', WORKFLOW_FIELDUPDATE));
                            nonEmptyRecord  = false;
                        }
                        workFlowFieldUpdateId = '';
                        workFlowFieldUpdateName = '';
                    }
                }
            }
        }
    }
    
    
    
    //SS code change starts
    
    public Set<string> setKeyprefix;
    Map<string,Map<string,string>> mapObjectFields = new Map<string, Map<string,string>>();   
    Map<string,string> mapCustomSettingNames = new Map<string,string>();
    Map<string,string> mapNameLabel = new Map<string,string>();    
        
    
      public void getObjectNames(){
        setKeyprefix = new set<string>{'001','003','02i','00P','701','00v','500','00a','010','800','015','00U','087','00Q','002','006','00k','01s','01u','01t','00E','501','00T','005'};
        
        for ( Schema.SObjectType typ : Schema.getGlobalDescribe().values() ) {
            //code to object name
            String sobjName = String.valueOf(typ);
            Schema.DescribeSObjectResult sobject_describe = typ.getDescribe();
                        
            if ( sobjName.contains('__c') || setKeyprefix.contains(sobject_describe.keyPrefix)){
              if(sobject_describe.isCustomSetting()){
                 String sobjLabel = sobject_describe.Label;                     
                 mapCustomSettingNames.put(  sobjName,   sobjLabel+'-!-'+sobject_describe.keyprefix);
                 
                
              }              
              else{
                String sobjLabel = sobject_describe.Label;                     
                mapNameLabel.put(  sobjName,   sobjLabel+'-!-'+sobject_describe.keyprefix);       
                                       
              }
            }                        
        }
   }
   
   //Set<string> setObjectAPINames ;
      public void getObjectFields()
   {
   
     try{
      for(string ObjName:mapNameLabel.keyset() ){
          getDescObjectFields(ObjName);  
       }
      for(string CSObjName:mapCustomSettingNames.keyset() ){
          getDescObjectFields(CSObjName);  
       } 
      }
      
      catch(Exception ex)
      {
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage()));   
      } 
   }
   
      public void getDescObjectFields(string sObjName){
            //code to get object fields and put in a map..for object and respective fields                              
            Map<String, Schema.SObjectField> Objfieldsdesc = Schema.getGlobalDescribe().get(sobjName).getDescribe().fields.getMap();
               list<Schema.SObjectField> Objfields = Objfieldsdesc.Values();    
               Map<string,string>  mapFieldMap = new Map<string,string>();
                   for (integer i = 0; i < objfields.size(); i++) { 
                                              
                       Schema.DescribeFieldResult nameFieldDesc = objfields[i].getDescribe(); 
                       String FieldLabel = '';
                       if(mapCustomSettingNames.get(sObjName) != null ){
                          FieldLabel = nameFieldDesc.getLabel() + '-!-'+ mapCustomSettingNames.get(sObjName) ;
                       }
                       else if(mapNameLabel.get(sObjName) != null){
                          FieldLabel = nameFieldDesc.getLabel() + '-!-'+ mapNameLabel.get(sObjName) ;                                              
                       }
                       
                       mapFieldMap.put(nameFieldDesc.getName(),FieldLabel);
                       system.debug('--field map--'+nameFieldDesc.getName());
                     
                  } 
                 if(mapFieldMap.size() >0){
                   mapObjectFields.put(sobjName,mapFieldMap);
                 }
        }  
         
    //SS code change ends
   
    
}