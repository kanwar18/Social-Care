/**************************************************************************
Test Class:  Social_StreamingUtil_Test
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Test class for class Social_StreamingUtil.
Version History: Aditya(14/March/2014) - Release 16June2014
*********************************************************************************************************************/

@isTest
Public class Social_StreamingUtil_Test {
    static testMethod void getRecordTypeIdTest() {
        Social_StreamingUtil.getRecordTypeId('GCS-GEN');
        Social_StreamingUtil.getRecordTypeId('GCS-D-S-L');
        Social_StreamingUtil.getRecordTypeId('GCS-UVERSE');
        Social_StreamingUtil.getRecordTypeId('GCS-IPHONE');
        Social_StreamingUtil.getRecordTypeId('GCS-IPAD');
        Social_StreamingUtil.getRecordTypeId('GCS-LANDLINE');
        Social_StreamingUtil.getRecordTypeId('GCS-WIRELESS');
        Social_StreamingUtil.getRecordTypeId('GCS-SALESLEAD');
        Social_StreamingUtil.getRecordTypeId('GCS-BLACKLIST');
        Social_StreamingUtil.getRecordTypeId('GCS-AMS');
        Social_StreamingUtil.getRecordTypeId('GCS-HIGHINFLUENCER');
        Social_StreamingUtil.getRecordTypeId('GCS-PRODUCT-OFFERS');
        Social_StreamingUtil.getRecordTypeId('GCS-CELEBRITY');
        Social_StreamingUtil.getRecordTypeId('GCS-BUSINESSLEADER');
        Social_StreamingUtil.getRecordTypeId('GCS-ESCALATION');
        Social_StreamingUtil.getRecordTypeId('ABS REVIEW-CARE');
        Social_StreamingUtil.getRecordTypeId('ABS CARE');
        Social_StreamingUtil.getRecordTypeId('DSL');
    }
}