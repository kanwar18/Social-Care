@istest(SeeAllData=true)
class Test_Package {
    Static testmethod void testController(){
        PageReference pageRef = Page.VFP01_StringSearch;
        Test.setCurrentPageReference(pageRef);
        
        VFC01_StringSearch controller = new VFC01_StringSearch();
        controller.yourString='Test';
        controller.isApexClass=True;
        controller.isApexTrigger=True;
        controller.isApexPage=True;
        controller.isEmailTemplate=True;
        controller.isProfile=True;
        controller.isApexComponent=True;
        controller.isSearchAll=True;
        controller.isGroup=True;
        controller.isPermissionSet=True;
        controller.isRole=True;
        controller.isReport=True;
        controller.isDashboard=True;
        controller.isStaticResource=True;
        controller.isSites=True;
        controller.isRecordType=True;
        controller.isDocument=True;
        controller.isAttachment=True;
        
        controller.isObject=True;
        controller.isCustomSetting=True;
        controller.isCustomSettingField=True;
        controller.isField=True;
        controller.isValidationRule=True;
        controller.isWorkflowRule=True;
        controller.isWorkflowFieldUpdate=True;
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        controller.search();
    }
   
    Static testmethod void testController1() {
        PageReference pageRef = Page.VFP01_StringSearch;
        Test.setCurrentPageReference(pageRef);
        
        VFC01_StringSearch controller = new VFC01_StringSearch();
        controller.yourString='Test';
        controller.isApexClass=True;
        controller.isApexTrigger=True;
        controller.isApexPage=True;
        controller.isEmailTemplate=True;
        controller.isProfile=True;
        controller.isApexComponent=True;
        controller.isSearchAll=True;
        controller.isGroup=True;
        controller.isPermissionSet=True;
        controller.isRole=True;
        controller.isReport=True;
        controller.isDashboard=True;
        controller.isStaticResource=True;
        controller.isSites=True;
        controller.isRecordType=True;
        controller.isDocument=True;
        controller.isAttachment=True;
        
        controller.isObject=True;
        controller.isCustomSetting=True;
        controller.isCustomSettingField=True;
        controller.isField=True;
        controller.isValidationRule=True;
        controller.isWorkflowRule=True;
        controller.isWorkflowFieldUpdate=True;
        controller.searchRadioButton ='FileName';
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        controller.search();
        controller.changePageSize();
        //controller.previousPage();
        controller.nextPage();
        controller.onclickaction();
        boolean test1=controller.getNextPageEnabled();
        boolean test2=controller.getPreviousPageEnabled();
        Integer i = controller.getTotalPageCount();
        system.assertEquals(controller.flag,true);
        List<selectoption> lst= controller.getItems();
        INNER01_StringSearch obj= new INNER01_StringSearch('Acount', 'Object', '','001' , '', 'Object');
    }
}