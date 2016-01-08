/*
*                                                                                                 *
*                            Version 1.20                                                         *
*                                                                                                 *
* Creation Date: 7.Nov.2014                    Aditya Kumar                                       *
* Last Modified: 7.Nov.2014                    Aditya Kumar                                       *
*                                                                                                 *
*                             © 2008 - Accenture - All Rights Reserved                            *

*/

@isTest
Global class MockHTTPResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"FullName":"test.TestRule","errorConditionFormula":"TestCondition","field":"testField","WorkflowRule":"WorkflowRule","url":"/07M900000021Zwp","field":"test.TestField"}');
        res.setStatusCode(200);
        return res;
    }
}