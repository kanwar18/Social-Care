/*
*                                                                                                 *
*                            Version 1.20                                                         *
*                                                                                                 *
* Creation Date: 04.Jun.2012                    Sameer N Miraj                                    *
* Last Modified: 07.Nov.2014                    Aditya                                            *
*                                                                                                 *
*                             © 2008 - Accenture - All Rights Reserved                            *

*/

public class VFC01_GenericHighLighter{

    //The code that needs to be highlighted.
    public String inputTextAreaBody{get;set;}
    
    //the string that was input from the user.
    public String searchString {get;set;}
    public boolean displayErrorMsg{get;set;}
    Public static final String COMP_NAME_WORKFLOW_RULE = 'WorkflowRule';
    Public static final String COMP_NAME_VALIDATION_RULE = 'ValidationRule';
    Public static final String ERROR_STRING = 'Error Occured';
    
    // ============================================================================
    // = C.O.N.S.T.R.U.C.T.O.R
    // ============================================================================
    public VFC01_GenericHighLighter(){
        String componentName = ApexPages.currentPage().getParameters().get('componentName');
        String componentId = ApexPages.currentPage().getParameters().get('componentId');
        searchString = ApexPages.currentPage().getParameters().get('searchValue');
        displayErrorMsg = false;
        if (componentName == 'apexClass'){
            inputTextAreaBody = [select body from apexclass where id = :componentId limit 1 ].body;
        }
        else if (componentName == 'visualForcePage' ){
            inputTextAreaBody = [select markup from ApexPage where id = :componentId limit 1 ].markup;
        }
        else if (componentName == 'triggers'){
           inputTextAreaBody  = [Select  body from ApexTrigger where id = :componentId limit 1 ].body;
            
        }
        else if (componentName == 'visualForceComponent'){
            inputTextAreaBody = [select markup from ApexComponent where id = :componentId limit 1 ].markup;
        }
        else if (componentName == 'Email Templates'){
            inputTextAreaBody = [select body from EmailTemplate where id = :componentId limit 1 ].body;
        } 
        else if (COMP_NAME_VALIDATION_RULE.equalsignorecase(componentName)) {
            try {
                String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                String url =  salesforceHost + '/services/data/v30.0/tooling/query/?q=Select+fullname+,metadata+from+ValidationRule+where+id+=+\''+componentId+'\'';
                HttpRequest req = new HttpRequest();
                req.setMethod(VFC01_StringSearch.GET);
                req.setEndpoint(url);
                req.setHeader(VFC01_StringSearch.CONTENT_TYPE, VFC01_StringSearch.APPLICATION_JSON);
                req.setHeader(VFC01_StringSearch.AUTHORIZATION, VFC01_StringSearch.BEARER + UserInfo.getSessionId());
                Http http = new Http();
                HTTPResponse res = http.send(req);
                //Check web service resposne
                if (res.getStatusCode() == 200) {
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) {
                        //Read workflow rule criteria
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == VFC01_StringSearch.ERRORCONDITIONFORMULA) {
                            parser.nextTOKEN();
                            inputTextAreaBody = parser.getText();
                        }
                    }
                } else {
                    displayErrorMsg = true;
                }
            } catch (Exception ex) {
                system.debug(ERROR_STRING + ex.getMessage());
            }
        } else if (COMP_NAME_WORKFLOW_RULE.equalsignorecase(componentName)) {
            try {
                String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                String url =  salesforceHost + '/services/data/v30.0/tooling/query/?q=Select+fullname+,metadata+from+WorkflowRule+where+id+=+\''+componentId+'\'';
                HttpRequest req = new HttpRequest();
                req.setMethod(VFC01_StringSearch.GET);
                req.setEndpoint(url);
                req.setHeader(VFC01_StringSearch.CONTENT_TYPE, VFC01_StringSearch.APPLICATION_JSON);
                req.setHeader(VFC01_StringSearch.AUTHORIZATION, VFC01_StringSearch.BEARER + UserInfo.getSessionId());
                Http http = new Http();
                HTTPResponse res = http.send(req);
                //Check web service resposne
                if (res.getStatusCode() == 200) {
                    String booleanValue = '';
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) {
                        //Read workflow rule filter condition
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == VFC01_StringSearch.FIELD) {
                            parser.nextValue();
                            inputTextAreaBody = parser.getText();
                            While (parser.nextValue() != null) {
                                if (parser.getCurrentName() == 'field') {
                                    inputTextAreaBody += ',' + '\n' + parser.getText();
                                }
                            }
                        //Read workflow rule Boolean filter
                        } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == VFC01_StringSearch.BOOLEANFILTER) {
                            parser.nextValue();
                            booleanValue = parser.getText();
                        //Read workflow rule formula
                        } else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == VFC01_StringSearch.FORMULA) {
                            parser.nextValue();
                            inputTextAreaBody = parser.getText();
                        }
                    }
                    if (booleanValue != 'null') {
                        inputTextAreaBody += '\n' + '\n' +  booleanValue;
                    }
                //Display error message in case of any failure
                } else {
                    displayErrorMsg = true;
                }
            } catch (Exception ex) {
                system.debug(ERROR_STRING + ex.getMessage());
            }
        }
    }
}