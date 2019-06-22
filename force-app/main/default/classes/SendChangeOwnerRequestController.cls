public class SendChangeOwnerRequestController {
    public SendChangeOwnerRequestController() {}


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : send link to approval page to team lead and redirect to account
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : 
    *  Parameters      : 
    *  Returns         : PageReference – return to account
    ******************************************************************************/
    public void init() {
        try {
            String accountId = ApexPages.CurrentPage().getparameters().get('id');
            if (accountId == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid account id. Please try again.'));
                return;
            }
            List<Account> account = [
                    SELECT Name, Active_Change_Owner_Request__c 
                    FROM Account 
                    WHERE Id = :accountId];
            if (account.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid account. Please contact your administrator.'));
                return;
            } 
            if (account.get(0).Active_Change_Owner_Request__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Request was already sent.'));
                return;
            }
            List<UserRole> rolesList = [SELECT Name, ParentRoleId FROM UserRole WHERE Id = :UserInfo.getUserRoleId()];
            if (rolesList.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid role.'));
                return;
            } else if ( ! rolesList.get(0).Name.contains('Salesteam') ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Salesteam Outbound and Inbound teams are able to send request only.'));
                return;
            }

            List<User> teamLeadsList = [
                    SELECT Id, Name
                    FROM User
                    WHERE IsActive = TRUE AND 
                          UserRoleId = :rolesList.get(0).ParentRoleId
                    LIMIT 1000];

            List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
            List<User> robert = [SELECT Id FROM User WHERE Name = 'Robert Kobrynski' LIMIT 1];
            for (User user : teamLeadsList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSenderDisplayName('Change Owner Request');
                email.saveAsActivity = false;
                String emailBody = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' has requested to take ownership of the account: <a href="/' + 
                                   accountId + '">' + account.get(0).Name + '</a>.<br/><br/>' + 
                                   '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/changeownerrequest?id=' + accountId + '&d=1&newOwnerId=' + UserInfo.getUserId() + '">Approve</a><br/>' + 
                                   '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/changeownerrequest?id=' + accountId + '&d=0&newOwnerId=' + UserInfo.getUserId() + '">Reject</a>';
                email.setHtmlBody(emailBody);
                if (user.Name == 'Rutger Geerts' && ! robert.isEmpty()) {
                    email.setTargetObjectId(robert.get(0).Id);    
                } else {
                    email.setTargetObjectId(user.Id);
                }
                email.setSubject('Change Owner Request');
                emailsList.add(email);
            }   

            Messaging.sendEmail(emailsList);
            account.get(0).Active_Change_Owner_Request__c = true;
            update account;

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Request has been sent. <a href="/' + accountId +'">Back to account</a>.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please contact your administrator. ' + e.getMessage()));
        }
    }
}