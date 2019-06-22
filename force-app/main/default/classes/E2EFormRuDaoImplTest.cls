@isTest
public class E2EFormRuDaoImplTest {

    public static void initPagesStructure() {
        E2EFormRuTestUtils.createLongFormRU();
        E2EFormRuTestUtils.createContactDetailsStep();
        E2EFormRuTestUtils.createCompanyInformationStep();
        E2EFormRuTestUtils.createOrderStep();
        E2EFormRuTestUtils.createLegalDetailsStep();
        E2EFormRuTestUtils.createPaymentDetailsStep();
    }

    // ***** Content Dao ***** //
    @isTest
    public static void testContentDao() {
        initPagesStructure();

        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        // get long form pages
        Set<String> elementsOfStep = new Set<String>{'CONTACT DETAILS', 'ORDER'};
        Map<Id, LongForm_Page__c> pageMap = e2eFormRuDao.getLongFormPages('Russia', elementsOfStep, 'Desktop');
        System.assertEquals(true, !pageMap.isEmpty());

        // get elements list by pages
        List<LongForm_Element__c> elementList = e2eFormRuDao.getElementsListByPages(pageMap.keySet());
        System.assertEquals(true, elementList.size() > 0);


        // get products by offer
        Set<Id> offerIds = new Set<Id>();
        for (LongForm_Element__c element : elementList) {
            for (LongForm_Offer__c offer : element.LongForm_Offers__r) {
                offerIds.add(offer.Id);
            }
        }
        Map<Id, LongForm_Fleetcor_Product__c> productMap = e2eFormRuDao.getProductsByOffer(offerIds);
        System.assertEquals(true, !productMap.isEmpty());

        // get tariffs by product
        Map<Id, LongForm_Tariff__c> tariffMap = e2eFormRuDao.getTariffsByProduct(productMap.keySet());
        System.assertEquals(true, !tariffMap.isEmpty());

        // get properties by tariff
        Map<Id, LongForm_Property__c> propertyMap = e2eFormRuDao.getPropertiesByTariff(tariffMap.keySet());
        System.assertEquals(true, !propertyMap.isEmpty());

        // get offers by ids
        Map<Id, LongForm_Offer__c> offerMap = e2eFormRuDao.getOffersByIds(offerIds);
        System.assertEquals(true, !offerMap.isEmpty());
    }


    // ***** User Dao ***** //
    @isTest
    public static void testUserDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        // get one user by name
        User templateUser = E2EFormRuTestUtils.createUser();
        insert templateUser;
        User existingUser = e2eFormRuDao.getUserByName('User Test');
        System.assertEquals(true, existingUser.Id != null);

        // get users By names
        User templateUser2 = E2EFormRuTestUtils.createUser();
        templateUser2.Username = 'new_user2_email@email.ru';
        templateUser2.LastName = 'Test 2';
        insert templateUser2;

        Map<Id, User> users = e2eFormRuDao.getUsersByNames(new Set<String>{
                'User Test', 'User Test 2'
        });
        System.assertEquals(true, !users.isEmpty());

        // get users by user role id
        List<User> usersList = e2eFormRuDao.getUsersByUserRoleId(new Set<Id>{
                templateUser.UserRoleId
        });
        System.assertEquals(true, usersList.size() > 0);

        // get users map by ids
        Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(new Set<Id>{
                usersList.get(0).Id, usersList.get(1).Id
        });
        System.assertEquals(true, usersMap.size() == 2);
    }

    // ***** Lead Dao ***** //
    @isTest
    public static void testLeadDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Lead lead = E2EFormRuTestUtils.createDefaultLead();
        insert lead;

        Lead newLead = E2EFormRuTestUtils.createDefaultLead();
        insert newLead;

        // get duplicated leads
        List<Lead> leadList = e2eFormRuDao.getDuplicatedLeads(newLead.Email, newLead.Phone);
        System.assertEquals(true, leadList.size() == 2);

        // update leads
        lead.Company = 'ООО Технология';
        newLead.Company = 'ООО Технология+';
        List<Lead> leadsForUpdate = new List<Lead>();
        leadsForUpdate.add(lead);
        leadsForUpdate.add(newLead);

        e2eFormRuDao.updateLeads(leadsForUpdate);
        System.assertEquals(true, leadsForUpdate.get(0).Company == 'ООО Технология');
        System.assertEquals(true, leadsForUpdate.get(1).Company == 'ООО Технология+');
    }

    // ***** Account Dao ***** //
    @isTest
    public static void testAccountDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Account templateAccount = E2EFormRuTestUtils.createDefaultAccount();
        templateAccount.INN__c = '11122233';

        // create account
        Id newAccountId = e2eFormRuDao.createAccount(templateAccount);
        System.assertEquals(true, newAccountId != null);

        // get account by id
        Account existingAccount = e2eFormRuDao.getAccountById(templateAccount.Id);
        System.assertEquals(true, existingAccount.Id != null);
        System.assertEquals(true, existingAccount.Name == 'E2E RU Account Test');

        // update account
        templateAccount.Name = 'E2E Account RU New Name';
        Id updatedAccountId = e2eFormRuDao.updateAccount(templateAccount);
        System.assertEquals(true, templateAccount.Name == 'E2E Account RU New Name');

        // get accounts by INN
        List<Account> existingAccounts = e2eFormRuDao.getAccountsByINN('11122233');
        System.assertEquals(true, existingAccounts.size() == 1);

        // get accounts by ids
        Account templateAccount2 = E2EFormRuTestUtils.createDefaultAccount();
        templateAccount2.INN__c = '22233344';
        insert templateAccount2;

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(templateAccount.Id);
        accountIds.add(templateAccount2.Id);

        Map<Id, Account> accountsByIds = e2eFormRuDao.getAccountsByIds(accountIds);
        System.assertEquals(true, accountsByIds.size() == 2);

        // delete account
        e2eFormRuDao.deleteAccount(templateAccount2);
        List<Account> deletedAccount = [SELECT id FROM Account WHERE Id = :templateAccount2.Id LIMIT 1];
        System.assertEquals(true, deletedAccount.size() == 0);
    }

    // ***** Contact Dao ***** //
    @isTest
    public static void testContactsDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Account templateAccount = E2EFormRuTestUtils.createDefaultAccount();

        // create contact
        Contact contact = E2EFormRuTestUtils.createDefaultContact();
        Id newContactId = e2eFormRuDao.createContact(contact);
        System.assertEquals(true, newContactId != null);

        // get contact by email
        List<Contact> contactsByEmail = e2eFormRuDao.getContactsByEmail('e2etest@e2etest.ru');
        System.assertEquals(true, contactsByEmail.size() == 1);

        // create contacts list
        List<Contact> templateListContacts = new List<Contact>();
        Contact contact1 = E2EFormRuTestUtils.createDefaultContact();
        templateListContacts.add(contact1);
        Contact contact2 = E2EFormRuTestUtils.createDefaultContact();
        templateListContacts.add(contact2);

        List<Contact> existingContacts = e2eFormRuDao.createContacts(templateListContacts);
        System.assertEquals(true, existingContacts.size() == 2);

        // get contact by id
        Contact existingContact = e2eFormRuDao.getContactById(contact1.Id);
        System.assertEquals(true, existingContact.Id != null);
        System.assertEquals(true, existingContact.FirstName == 'Contact Test');

        // update contact
        contact1.Email = 'e2etestNEW@e2etestNEW.ru';
        Id updatedContactId = e2eFormRuDao.updateContact(contact1);
        System.assertEquals(true, contact1.Email == 'e2etestNEW@e2etestNEW.ru');

        // get contact by domain
        List<Contact> contactsByDomain = e2eFormRuDao.getContactsByDomain('e2etestNEW.ru');
        System.assertEquals(true, contactsByDomain.size() == 1);

        // get contacts by name & phone & email
        List<Contact> contactsByNamePhoneEmail = e2eFormRuDao.getContactsByNamePhoneEmail('E2E', '+7 (922) 233-33-22', 'e2etest@e2etest.ru', '');
        System.assertEquals(true, contactsByNamePhoneEmail.size() == 2);

        // get contacts by last name
        List<Contact> contactsByLastName = e2eFormRuDao.getContactsByLastName('E2E');
        System.assertEquals(true, contactsByLastName.size() == 3);

        // get contacts by account and contact title
        List<Contact> contactsByAccountAndTitle = e2eFormRuDao.getContactsByAccountAndTitle(contact.AccountId, contact.Title);
        System.assertEquals(true, contactsByAccountAndTitle.size() == 3);
    }

    // ***** Opportunity Dao ***** //
    @isTest
    public static void testOpportunityDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Opportunity templateOpportunity = E2EFormRuTestUtils.createDefaultOpportunity();

        // create opportunity
        Id newOpportunityId = e2eFormRuDao.createOpportunity(templateOpportunity);
        System.assertEquals(true, newOpportunityId != null);

        // get opportunity by id
        Opportunity existingOpportunity = e2eFormRuDao.getOpportunityById(newOpportunityId);
        System.assertEquals(true, existingOpportunity.Id != null);
        System.assertEquals(true, existingOpportunity.Name == 'E2E Opportunity Test');

        // update opportunity
        templateOpportunity.Name = 'E2E Opportunity Test New';
        Id updatedOpportunityId = e2eFormRuDao.updateOpportunity(templateOpportunity);
        System.assertEquals(true, templateOpportunity.Name == 'E2E Opportunity Test New');

        // update opportunities
        List<Opportunity> templateListOpportunities = new List<Opportunity>();
        Opportunity opportunity1 = E2EFormRuTestUtils.createDefaultOpportunity();
        opportunity1.Name = 'E2E Opportunity Test Updated';
        opportunity1.OwnerId = UserInfo.getUserId();
        templateListOpportunities.add(opportunity1);
        Opportunity opportunity2 = E2EFormRuTestUtils.createDefaultOpportunity();
        opportunity2.Name = 'E2E Opportunity Test Updated';
        opportunity2.OwnerId = UserInfo.getUserId();
        templateListOpportunities.add(opportunity2);
        insert templateListOpportunities;

        e2eFormRuDao.updateOpportunities(templateListOpportunities);
        System.assertEquals(true, opportunity1.Name == 'E2E Opportunity Test Updated');
        System.assertEquals(true, opportunity2.Name == 'E2E Opportunity Test Updated');

        // get last modified stage by opportunity id
        List<OpportunityHistory> oppHistory = e2eFormRuDao.getLastModifiedStageByOpportunityId(opportunity1.Id);
        System.assertEquals(true, oppHistory.size() == 0);

        //**********getOpportunitiesByIds test*****************//
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Opportunity opportunity : templateListOpportunities) {
            testOpportunities.add(new Opportunity(Id = opportunity.Id, OwnerId = opportunity.OwnerId));
        }
        Set<Id> testOpportunityIds = new Set<Id>();
        for (Opportunity opportunity: testOpportunities) {
            testOpportunityIds.add(opportunity.Id);
        }
        List<Opportunity> refusingOpportunityList = e2eFormRuDao.getOpportunitiesByIds(new Set<Id>(testOpportunityIds));
        System.assertEquals(templateListOpportunities.size(), refusingOpportunityList.size());
        System.assertEquals(testOpportunities, refusingOpportunityList);
        System.debug('testOpportunities = ' + testOpportunities);
        System.debug('refusingOpportunityList = ' + refusingOpportunityList);
    }

    // ***** OpportunityContactRole Dao ***** //
    @isTest
    public static void testOpportunityContactRoleDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Opportunity templateOpportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        insert templateOpportunity;

        Contact templateContact = E2EFormRuTestUtils.createDefaultContact();
        insert templateContact;
        OpportunityContactRole contactRole = new OpportunityContactRole(
                OpportunityId = templateOpportunity.Id,
                Role = 'Accountant',
                IsPrimary = true,
                ContactId = templateContact.Id
        );

        Contact templateContact2 = E2EFormRuTestUtils.createDefaultContact();
        insert templateContact2;
        OpportunityContactRole contactRole2 = new OpportunityContactRole(
                OpportunityId = templateOpportunity.Id,
                Role = 'Accountant administrator',
                IsPrimary = false,
                ContactId = templateContact2.Id
        );

        // get opportunity contact role
        OpportunityContactRole existingContactRole = e2eFormRuDao.getOpportunityContactRole(templateContact.Id, templateOpportunity.Id);
        System.assertEquals(true, existingContactRole.Role == 'Decision Maker');

        // create opportunity contact role
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        opportunityContactRoles.add(contactRole);
        opportunityContactRoles.add(contactRole2);

        e2eFormRuDao.createOpportunityContactRole(opportunityContactRoles);
        System.assertEquals(true, contactRole.Id != null);
        System.assertEquals(true, contactRole2.Id != null);

        // get opportunity contact roles by contact and opportunity ids
        List<OpportunityContactRole> oppContactRoles = e2eFormRuDao.getOpportunityContactRoles(templateContact.Id, templateOpportunity.Id);
        System.assertEquals(true, oppContactRoles.size() == 1);
    }

    // ***** Form Service ***** //
    @isTest
    public static void testFormDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();

        // create form data record
        Id formDataId = e2eFormRuDao.createFormDataRecord(formData);
        System.assertEquals(true, formData.Id != null);

        // update form data
        formData.E2E_INN__c = '11122233';
        Id updatedFormDataId = e2eFormRuDao.updateFormData(formData);
        System.assertEquals(true, formData.E2E_INN__c == '11122233');

        // get form data by id
        E2EFormData__c existingFormData = e2eFormRuDao.getFormDataById(formDataId);
        System.assertEquals(true, existingFormData != null);

        // get form data by account id and contact id
        Contact contact = E2EFormRuTestUtils.createDefaultContact();
        formData.E2E_Account_Id__c = contact.AccountId;
        formData.E2E_Contact_Id__c = contact.Id;
        List<E2EFormData__c> formDataList = e2eFormRuDao.getFormDataByAccountIdAndContactId(contact.AccountId, contact.Id);
        System.assertEquals(true, !formDataList.isEmpty());
    }

    // ***** Document Dao ***** //
    @isTest
    public static void testDocumentDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Document templateDocument = E2EFormRuTestUtils.createDefaultDocument();
    }

    // ***** EmailTemplate Dao ***** //
    @IsTest
    public static void testEmailTemplateDao() {
        E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();

        User guest = ([
                SELECT Id, Name
                FROM User
                WHERE Name = 'E2E RU Site Guest User'
        ]);
        System.runAs(guest) {
            for (GlobalUtils.EmailTemplateDevName devName : GlobalUtils.EmailTemplateDevName.values()) {
                System.debug('DEVELOPER NAME: ' + devName.name());
                EmailTemplate template = e2EFormRuDao.getEmailTemplateByDevName(devName.name());
                System.assertNotEquals(null, template);
            }
        }
    }
}