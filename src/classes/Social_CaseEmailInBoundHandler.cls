/** This class implements the inbound Email handler for the custom email service setup
***/
global class Social_CaseEmailInBoundHandler implements Messaging.InboundEmailHandler {

/*** This method is used to invoke the Emailutilities Class where all the processing takes place **/
    global Messaging.InboundEmailResult handleInboundEmail(
       Messaging.InboundEmail email,
       Messaging.InboundEnvelope envelope) {
 Social_CaseEmailInBoundUtilities handler = new Social_CaseEmailInBoundUtilities();
        Messaging.InboundEmailResult result = handler.processInboundEmail(email);
        return result; 
    }
 
}