/*
*                                                                                                 *
*                            Version 1.02                                                         *
*                                                                                                 *
* Creation Date: 04.Jun.2012                    Sameer N Miraj                                    *
* Last Modified: 30.Oct.2013                    Veenesh Vikram/Sakshi Arora/Sushant Verma         *                                                                                               *
*                             © 2008 - Accenture - All Rights Reserved                            *
*/

public class INNER01_StringSearch{ 
    
    public String codeName {get; set;}
    Public String componentName {get; set;}
    Public String lineNumber {get;set;}
    public id codeId{get;set;}
    public string codeBody{get;set;}
    public string pseudoColumnName{get;set;}
    public string prefix{get;set;}
    // ============================================================================
    // = C.O.N.S.T.R.U.C.T.O.R
    // ============================================================================
    
    public INNER01_StringSearch(String cName, String component, String line, Id cId, String Body,String pseudoName) {
        this.codeName = cName;
        this.componentName = component;
        this.lineNumber = line;
        this.codeId = cId;
        this.codeBody =Body;
        this.pseudoColumnName = pseudoName;
    } 
    public INNER01_StringSearch(String cName, String component, String line, string prefix, String Body,String pseudoName) {
        this.codeName = cName;
        this.componentName = component;
        this.lineNumber = line;
        this.prefix = prefix;
        this.codeBody =Body;
        this.pseudoColumnName = pseudoName;
    } 
         
}