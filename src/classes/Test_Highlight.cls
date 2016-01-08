@istest(SeeAllData=true)
class Test_Highlight {

    Static testmethod void testHighlight() {
        apexclass ap01 = [select name,id,body from Apexclass limit 1];
        PageReference pageRef = Page.VFP01_GenericHighLighter;
        Test.setCurrentPageReference(pageRef);
        apexpages.currentpage().getparameters().put('componentName', 'apexclass');
        apexpages.currentpage().getparameters().put('componentId', ap01.id);
        apexpages.currentpage().getparameters().put('searchValue', 'test');
        
        VFC01_GenericHighLighter controller = new VFC01_GenericHighLighter();
    }

    Static testmethod void testHighlight1() {
        ApexPage ap = [Select id from Apexpage limit 1];
        PageReference pageRef = Page.VFP01_GenericHighLighter;
        Test.setCurrentPageReference(pageRef);
        apexpages.currentpage().getparameters().put('componentName', 'apexpage');
        apexpages.currentpage().getparameters().put('componentId', ap.id);
        apexpages.currentpage().getparameters().put('searchValue', 'test');
        
        VFC01_GenericHighLighter controller = new VFC01_GenericHighLighter();
    }


    Static testmethod void testHighlight2() {
        ApexTrigger apt = [Select id from ApexTrigger limit 1];
        PageReference pageRef = Page.VFP01_GenericHighLighter;
        Test.setCurrentPageReference(pageRef);
        apexpages.currentpage().getparameters().put('componentName', 'apextrigger');
        apexpages.currentpage().getparameters().put('componentId', apt.id);
        apexpages.currentpage().getparameters().put('searchValue', 'test');
        
        VFC01_GenericHighLighter controller = new VFC01_GenericHighLighter();
    }
    
    Static testmethod void testHighlight3() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        PageReference pageRef = Page.VFP01_GenericHighLighter;
        Test.setCurrentPageReference(pageRef);
        apexpages.currentpage().getparameters().put('componentName', 'ValidationRule');
        apexpages.currentpage().getparameters().put('componentId', 'ds');
        apexpages.currentpage().getparameters().put('searchValue', 'test');
        
        VFC01_GenericHighLighter controller = new VFC01_GenericHighLighter();
    }
    
    Static testmethod void testHighlight4() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        PageReference pageRef = Page.VFP01_GenericHighLighter;
        Test.setCurrentPageReference(pageRef);
        apexpages.currentpage().getparameters().put('componentName', 'WorkflowRule');
        apexpages.currentpage().getparameters().put('componentId', 'ds');
        apexpages.currentpage().getparameters().put('searchValue', 'test');
        
        VFC01_GenericHighLighter controller = new VFC01_GenericHighLighter();
    }
}