public class ApprovePprRequestFromEmailCtrl {

    public Boolean isGoToRecord { get; set; }
    public Boolean isCommentForRejectComboBox { get; set; }
    public Boolean isCommentForRejectTextArea { get; set; }
    public String reasonReject { get; set; }
    public String commentReject { get; set; }

    /*******************************************************************************
*  Name            : init()
*  Summary         : Start Method loaded from VF page
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : void
******************************************************************************/
    public void init() {
        isGoToRecord = false;
        isCommentForRejectComboBox = false;
        isCommentForRejectTextArea = false;
        String typeRequest = ApexPages.currentPage().getParameters().get('type');
        String answer = ApexPages.currentPage().getParameters().get('Answer');
        String idRecord = ApexPages.currentPage().getParameters().get('idRecord');
        String idNewOwner = ApexPages.currentPage().getParameters().get('idNewOwner');
        if (typeRequest == '001') {
            changeOwnerFromFindDuplicates(idRecord, idNewOwner, answer);
        } else if (typeRequest == '002') {
            changeOwnerRecordByTeamLead(idRecord, idNewOwner, answer);
        } else if (typeRequest == '003') {
            processingRequestForSecondOpportunity(idRecord, idNewOwner, answer);
        } else if (typeRequest == '004') {
            changeOwnerAccountByTeamLead(idRecord, idNewOwner, answer);
        }
    }

    /*******************************************************************************
*  Name            : goToRecord()
*  Summary         : return PageReference to record, that uses in page
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : PageReference
******************************************************************************/
    public PageReference goToRecord() {
        String idRecord = ApexPages.currentPage().getParameters().get('idRecord');
        return new PageReference('/' + idRecord);
    }

    /*******************************************************************************
*  Name            : getReasonsForReject()
*  Summary         : create list for combobox to chouse reject reason
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : List<SelectOption>
******************************************************************************/
    public List<SelectOption> getReasonsForReject() {
        List<SelectOption> listReasons = new List<SelectOption>();
        String typeRequest = ApexPages.currentPage().getParameters().get('type');
        if (typeRequest == '001') {
            List<RU_RejectReasonText__c> rejectReasonTexts = [
                    SELECT id,name,text__c,shorttext__c
                    FROM Ru_RejectReasonText__c
                    WHERE name LIKE 'RejectByAdmin%'
                    ORDER BY NAME
            ];
            for (Ru_RejectReasonText__c reasonText : rejectReasonTexts) {
                listReasons.add(new SelectOption(reasonText.text__c, reasonText.shorttext__c));
            }
        }
        return listReasons;
    }

    /*******************************************************************************
*  Name            : rejectRequest()
*  Summary         : action when user confirms reject
*  CreatedDate     : 01/11/2017
*  Parameters      : -
*  Returns         : void
******************************************************************************/
    public void rejectRequest() {
        try {
            String idRecord = ApexPages.currentPage().getParameters().get('idRecord');
            String idNewOwner = ApexPages.currentPage().getParameters().get('idNewOwner');
            String typeRequest = ApexPages.currentPage().getParameters().get('type');

            String rejectMessage = getReasonRejectMessage();

            if (typeRequest == '001') {
                List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                        'Результат запроса на запись',
                        '<p>Ваш запрос на получение записи "' + idRecord + '" был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                rejectMessage));
                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(Userinfo.getUserId(),
                        'Отклоненный запрос на запись',
                        '<p>Запрос на получение записи "' + idRecord + '" был Вами отклонен </p>' +
                                rejectMessage));
                Messaging.sendEmail(emailMessageList);

            } else if (typeRequest == '002') {
                List<Opportunity> listOwner = [SELECT ownerid from Opportunity WHERE id = :idRecord];
                EmailGenerator.sendHtmlEmail(listOwner.get(0).ownerid,
                        'Результат запроса на запись',
                        '<p>Ваш запрос на получение записи "' + idRecord + '" был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                rejectMessage
                );
            } else if (typeRequest == '003') {
                List<Opportunity> listOpportunities = [SELECT name, ownerid FROM Opportunity WHERE id = :idRecord AND ownerid = :UserInfo.getUserId()];
                if (listOpportunities.size() <> 0) {
                    EmailGenerator.sendHtmlEmail(idNewOwner,
                            'Результат запроса на запись',
                            '<p>Ваш запрос на создание второй в возможности ' + listOpportunities.get(0).name + ' был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                    rejectMessage
                    );
                    delete listOpportunities;
                }
            } else if (typeRequest == '004') {
                List<Account> listOwner = [SELECT ownerid from Account WHERE id = :idRecord];
                EmailGenerator.sendHtmlEmail(listOwner.get(0).ownerid,
                        'Результат запроса на запись',
                        '<p>Ваш запрос на перевод записи "' + idRecord + '" был отклонен ' + UserInfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
                                    rejectMessage);
            }
            isCommentForRejectComboBox = false;
            isCommentForRejectTextArea = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0012_RequestRejected));
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка' + ' ' + e.getMessage()));
        }
    }


    /*******************************************************************************
*  Name            : changeOwnerRecordByAdmin()
*  Summary         : type approve = 001. Change owner of Lead/Opportunity(Account) by Request from FindDuplicatesRu
*  CreatedDate     : 01/11/2017
*  Parameters      : (Id idRecord, Id idNewOwner, String answer)
*  Returns         : void
******************************************************************************/
    public void changeOwnerFromFindDuplicates(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Profile> profilesSysAdmin = [
                    SELECT id
                    FROM Profile
                    WHERE name = :Label.System_Administrator
            ];
            if ((profilesSysAdmin.isEmpty() == false) && (Userinfo.getProfileId() == profilesSysAdmin.get(0).id)) {
                if (answer == 'yes') {
                    String typeName = idRecord.getSObjectType().getDescribe().getName();
                    if (typeName == 'Lead') {
                        List<Lead> leadForUpdate = [
                                SELECT id, owner.id
                                FROM lead
                                WHERE id = :idRecord
                                AND ownerid <> :idNewOwner
                        ];
                        if (leadForUpdate.size() <> 0) {
                            for (Lead lead : leadForUpdate) {
                                lead.ownerid = idNewOwner;
                            }
                            update leadForUpdate;
                            isGoToRecord = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

                            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                            emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                                    'Результат запроса на запись',
                                    '<p>Ваш запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>'));
                            emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(UserInfo.getUserId(),
                                    'Утвержденнный запрос на запись',
                                    '<p>Запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> был Вами Утвержден!</p>'));
                            Messaging.sendEmail(emailMessageList);
                        }
                    } else if (typeName == 'Opportunity') {
                        List<Opportunity> targetOpportunity = [
                                SELECT id, owner.id, account.id, owner.email
                                FROM Opportunity
                                WHERE id = :idRecord
                                AND ownerid <> :idNewOwner
                        ];
                        if (targetOpportunity.size() == 1) {
                            List<Account> accountsForUpdate = [
                                    SELECT id, owner.id
                                    FROM Account
                                    WHERE id = :targetOpportunity.get(0).account.id
                            ];
                            if (accountsForUpdate.size() == 1) {
                                Account accountForUpdate = accountsForUpdate.get(0);
                                accountForUpdate.ownerid = idNewOwner;
                                update accountForUpdate;

                                List<Opportunity> opportunitiesForUpdate = [
                                        SELECT id, owner.id, account.id
                                        FROM Opportunity
                                        WHERE account.id = :accountForUpdate.id AND
                                        StageName <> 'Moved to Start'
                                ];
                                for (Opportunity opportunityForUpdate : opportunitiesForUpdate) {
                                    opportunityForUpdate.ownerid = idNewOwner;
                                }
                                update opportunitiesForUpdate;

                                isGoToRecord = true;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

                                List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                                        'Результат запроса на запись',
                                        '<p>Ваш запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>'));
                                emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(UserInfo.getUserId(),
                                        'Утвержденнный запрос на запись',
                                        '<p>Запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> был Вами Утвержден!</p>'));
                                Messaging.sendEmail(emailMessageList);
                            }
                        }
                    }
                } else if (answer == 'no') {
                    isCommentForRejectComboBox = true;
                    isCommentForRejectTextArea = true;
                    isGoToRecord = true;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0013_NoAccess));
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }

    /*******************************************************************************
*  Name            : changeOwnerRecordByAdmin()
*  Summary         : type approve = 002. Change owner of Opportunity(Account) by Request from RussianSalesManager to his Manager(=TeamLeader)
*  CreatedDate     : 01/11/2017
*  Parameters      : (Id idRecord, Id idNewOwner, String answer)
*  Returns         : void
******************************************************************************/
    public void changeOwnerRecordByTeamLead(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Opportunity> currentOpportunities = [
                    SELECT id, ownerid, owner.managerid, account.id
                    FROM Opportunity
                    WHERE id = :idRecord
                    AND Owner.ManagerId = :UserInfo.getUserId()
                    AND StageName <> 'Moved to Start'
            ];
            if (currentOpportunities.size() == 1) {
                if (answer == 'yes') {
                    String idOldOwner = currentOpportunities.get(0).ownerid;
                    List<Account> accountsForUpdate = [
                            SELECT id, owner.id, Opportunity_Sum__c
                            FROM Account
                            WHERE id = :currentOpportunities.get(0).account.id
                            AND Moved_to_Start__c = 0
                    ];
                    if (accountsForUpdate.size() == 1) {
                        if (accountsForUpdate.get(0).Opportunity_Sum__c == 1){
                            for (Account accountForUpdate : accountsForUpdate) {
                                accountForUpdate.ownerid = idNewOwner;
                            }
                            update accountsForUpdate;
                        }
                        for (Opportunity opportunity : currentOpportunities) {
                            opportunity.ownerid = idNewOwner;
                        }
                        update currentOpportunities;

                        isGoToRecord = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

                        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                        emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idOldOwner,
                                'Результат запроса на перевод',
                                '<p>Ваш запрос на перевод записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>'));
                        emailMessageList.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                                'Результат перевода записи',
                                '<p>На вас переведена возможность <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a></p>'));
                        Messaging.sendEmail(emailMessageList);
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0007_OwnerCanNotBeChanged));
                    }
                } else if (answer == 'no') {
                    isCommentForRejectTextArea = true;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0007_OwnerCanNotBeChanged));
            }

        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }

    /*******************************************************************************
*  Name            : processingRequestForSecondOpportunity()
*  Summary         : type approve = 003. change owner from Team Lead to Manager (processing request for create second opportunity)
*  CreatedDate     : 13/11/2017
*  Parameters      : (Id idRecord, Id idNewOwner, String answer)
*  Returns         : void
******************************************************************************/
    public void processingRequestForSecondOpportunity(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Opportunity> currentOpportunities = [
                    SELECT id, ownerid, owner.managerid
                    FROM Opportunity
                    WHERE id = :idRecord
                    AND ownerid = :UserInfo.getUserId()
            ];
            if (currentOpportunities.size() == 1) {
                List<User> newOwnerOfRecord = [
                        SELECT name, ManagerId
                        FROM User
                        WHERE id = :idNewOwner
                        AND ManagerId = :UserInfo.getUserId()
                ];
                if (newOwnerOfRecord.size() == 1) {
                    if (answer == 'yes') {
                        for (Opportunity opportunity : currentOpportunities) {
                            opportunity.ownerid = idNewOwner;
                        }
                        update currentOpportunities;

                        isGoToRecord = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Запись утверждена'));
                        EmailGenerator.sendHtmlEmail(idNewOwner,
                                'Результат запроса на создание возможности',
                                '<p>Создание возможности <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утверждено </p>'
                        );
                    } else if (answer == 'no') {
                        isCommentForRejectTextArea = true;
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0013_NoAccess));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! Запрос по записи ' + idRecord + ' уже был обработан либо у вас недостаточно прав!'));
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
        }
    }


    /*******************************************************************************
    *  Name            : getReasonRejectMessage()
    *  Summary         : return reject message
    *  CreatedDate     : 31/1/2018
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String getReasonRejectMessage() {
        String messageReason = 'не указано';
        String messageComment = 'не указано';
        if(!String.isEmpty(reasonReject)) {
            messageReason = reasonReject;
        }

        if(!String.isEmpty(commentReject)) {
            messageComment = commentReject;
        }

        return '<p>Причина : ' + messageReason + '</p>' + '<p>Комментарий : ' + messageComment + '</p>';
    }

    /*******************************************************************************
    *  Name            : changeOwnerOfAccount()
    *  Summary         : type approve = 004. change owner of Account and Account.Opportunities
    *  CreatedDate     : 21/12/2017
    *  Parameters      : (Id idRecord, Id idNewOwner, String answer)
    *  Returns         : void
    ******************************************************************************/
    public void changeOwnerAccountByTeamLead(Id idRecord, Id idNewOwner, String answer) {
        try {
            List<Account> currentAccount = [
                    SELECT id, ownerid, Owner.ManagerId
                    FROM Account
                    WHERE id = :idRecord
                    AND Owner.ManagerId = :UserInfo.getUserId()
                    AND Moved_to_Start__c = 0
            ];
            if (currentAccount.size() == 1) {
                if (answer == 'yes') {
                    String idOldOwner = currentAccount.get(0).ownerid;
                    List<Opportunity> opportunitiesForUpdate = [
                            SELECT id, owner.id
                            FROM Opportunity
                            WHERE AccountId = :idRecord AND
                            OwnerId = :currentAccount.get(0).OwnerId
                    ];
                    for (Opportunity opportunityForUpdate : opportunitiesForUpdate) {
                        opportunityForUpdate.OwnerId = idNewOwner;
                    }
                    update opportunitiesForUpdate;

                    for (Account account : currentAccount) {
                        account.OwnerId = idNewOwner;
                    }
                    update currentAccount;

                    isGoToRecord = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0010_OwnerChanged));

                    List<Messaging.Email> emails = new List<Messaging.Email>();
                    emails.add(EmailGenerator.prepareHtmlEmailToTarget(idOldOwner,
                            'Результат запроса на перевод организации',
                            '<p>Ваш запрос на перевод записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a> Утвержден</p>'));
                    emails.add(EmailGenerator.prepareHtmlEmailToTarget(idNewOwner,
                            'Результат запроса на перевод организации',
                            '<p>На вас переведена организация <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idRecord + '" > ' + idRecord + ' </a></p>'));
                    Messaging.sendEmail(emails);
                } else if (answer == 'no') {
                    isCommentForRejectTextArea = true;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0007_OwnerCanNotBeChanged));
            }
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged + ' ' + e.getMessage()));
        }
    }
}