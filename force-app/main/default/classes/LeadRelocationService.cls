public class LeadRelocationService {
    private static final String LeadAssignAT = 'LeadAssignAT';
    private static final String LeadAssignDE = 'LeadAssignDE';
    private static final String LeadAssignNL = 'LeadAssignNL';
    private static final String LeadAssignPL = 'LeadAssignPL';
    private static final String LeadAssignFR = 'LeadAssignFR';
    private static final String LeadAssignHU = 'LeadAssignHU';
    private static final String LeadAssignBE_FR = 'LeadAssignBE_FR';
    private static final String LeadAssignBE_NL = 'LeadAssignBE_NL';
    private static final String LeadAssignCH_DE = 'LeadAssignCH_DE';
    private static final String LeadAssignCH_IT = 'LeadAssignCH_IT';
    private static final String LeadAssignCH_FR = 'LeadAssignCH_FR';
    private static final String LeadAssignLU = 'LeadAssignLU';
    private static final String LeadAssignCZ = 'LeadAssignCZ';
    private static final String LeadAssignSK = 'LeadAssignSK';
    private static final String LeadAssignAllStar = 'LeadAssignAllStar';
    private static final String RussianWebLeads = 'Russian Web Leads';
    private static final String LeadAssignPLJITB = 'LeadAssignPLJITB';
    private static final String LeadAssignHUJITB = 'LeadAssignHUJITB';
    public static final String siteurl = 'https://emea.salesforce.com/';

    public static Boolean isNeedToSend = false;


    /*******************************************************************************
    *  Name            : customLeadAssignExternalForm(Map<Id, Lead> newLeadsMap, Map<Id, Lead> oldLeadsmap)
    *  Summary         : check is_External checkbox and invoke customLeadAssign method
    *  CreatedDate     : 20/03/2017
    *  Parameters      : Map<Id, Lead> newLeadsMap - leads map with old values
                        Map<id, Lead> oldLeadsMap - leads map with new values
    *  Returns         : void
    ******************************************************************************/
    public static void customLeadAssignExternalForm(Map<Id, Lead> oldLeadsmap, Map<Id, Lead> newLeadsMap) { 
        List<Lead> externalLeadsList = new List<Lead>();
        for (Lead lead : newLeadsMap.values()) {
            if (lead.Is_External__c == false && oldLeadsmap.get(lead.Id).Is_External__c == true) {
                externalLeadsList.add(lead);
            }
        }

        if (! externalLeadsList.isEmpty()) {
            customLeadAssign(externalLeadsList);
        }
        List<String> listexcep;    
    }


    /*******************************************************************************
    *  Name            : customLeadAssign(List<Lead> leadsList)
    *  Summary         : Country before update = null
    *  CreatedDate     :
    *  Parameters      : List<Lead> leadsList
    *  Returns         : void
    ******************************************************************************/
    public static void customLeadAssign(List<Lead> leadsList) {
        String ccsRecordTypeId;
        if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CCS Sales process') != null) {
            ccsRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CCS Sales process').getRecordTypeId();
        } 
        List<Lead> newLeads = new List<Lead>();
        for (Lead lead : leadsList) {
            if (lead.RecordTypeId != ccsRecordTypeId && (lead.Recycle_counter__c == 0 || lead.Recycle_counter__c == null) && lead.Quali_Status__c != 'Switched to E2E') {
                newLeads.add(lead);
            }
        }
        List<AuthSession> alist = [
                SELECT Users.Name, LastModifiedDate, LoginType,
                        NumSecondsValid, SessionType, Users.Email,
                        UsersId
                FROM AuthSession
                WHERE SessionType = 'UI' AND 
                    (LoginType = 'Application' OR LoginType = 'Remote Access Client')
                LIMIT 10000];

        for (Integer i = 0; i < alist.size(); i ++) {
            if (alist.get(i).LastModifiedDate.addSeconds(alist.get(i).NumSecondsValid) < Datetime.now()) {
                alist.remove(i);
            }
        }
        
        //get all queues
        List<Group> queuesList = [
                SELECT Name, (SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMembers)
                FROM Group
                    WHERE Name = :LeadAssignAT OR Name = :LeadAssignDE OR Name = :LeadAssignNL OR
                    Name = :LeadAssignPL OR Name = :LeadAssignFR OR Name = :LeadAssignHU OR
                    Name = :LeadAssignBE_FR OR Name = :LeadAssignBE_NL OR Name = :LeadAssignCH_DE OR
                    Name = :LeadAssignCH_IT OR Name = :LeadAssignCH_FR OR Name = :LeadAssignLU OR
                    Name = :LeadAssignCZ OR Name = :LeadAssignSK OR Name = :LeadAssignAllStar  OR
                    Name = :RussianWebLeads OR Name = :LeadAssignPLJITB OR Name = :LeadAssignHUJITB
                LIMIT 10000];
        Map<String, List<Group>> queuesMap = new Map<String, List<Group>>();

        for (Group g : queuesList) {
            if ( ! queuesMap.containsKey(g.Name)) {
                queuesMap.put(g.Name, new List<Group>());
            }

            queuesMap.get(g.Name).add(g);
        }

        //LeadAssign
        Map<String, GroupMember> currentMembers_LeadAssignAT = selectGroupMember(LeadAssignAT, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignDE = selectGroupMember(LeadAssignDE, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignPL = selectGroupMember(LeadAssignPL, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignHU = selectGroupMember(LeadAssignHU, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignFR = selectGroupMember(LeadAssignFR, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignNL = selectGroupMember(LeadAssignNL, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignBE_FR = selectGroupMember(LeadAssignBE_FR, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignBE_NL = selectGroupMember(LeadAssignBE_NL, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCH_DE = selectGroupMember(LeadAssignCH_DE, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCH_IT = selectGroupMember(LeadAssignCH_IT, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCH_FR = selectGroupMember(LeadAssignCH_FR, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignLU = selectGroupMember(LeadAssignLU, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCZ = selectGroupMember(LeadAssignCZ, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignSK = selectGroupMember(LeadAssignSK, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignAllStar = selectGroupMember(LeadAssignAllStar, queuesMap);
        Map<String, GroupMember> currentMembers_RussianWebLeads = selectGroupMember(RussianWebLeads, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignPLJITB = selectGroupMember(LeadAssignPLJITB, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignHUJITB = selectGroupMember(LeadAssignHUJITB, queuesMap);

        //AT
        List<Lead> lastLeadOwner_LeadAssignAT = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Austria' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignAT.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //DE
        List<Lead> lastLeadOwner_LeadAssignDE = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Germany' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignDE.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //PL
        List<Lead> lastLeadOwner_LeadAssignPL = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                      Country = 'Poland' AND Owner.Type = 'User' AND
                      Last_Owner_Change_Date__c != NULL AND
                      LeadSource != 'Inbound Call' AND
                      isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignPL.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //PL JITB
        List<Lead> lastLeadOwner_LeadAssignPLJITB = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                      Country = 'Poland' AND Owner.Type = 'User' AND
                      Last_Owner_Change_Date__c != NULL AND
                      LeadSource != 'Inbound Call' AND
                      isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignPLJITB.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //HU
        List<Lead> lastLeadOwner_LeadAssignHU = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Hungary' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignHU.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //HU JITB
        List<Lead> lastLeadOwner_LeadAssignHUJITB = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                      Country = 'Hungary' AND Owner.Type = 'User' AND
                      Last_Owner_Change_Date__c != NULL AND
                      LeadSource != 'Inbound Call' AND
                      isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignHUJITB.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];                

        //FR
        List<Lead> lastLeadOwner_LeadAssignFR = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'France' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignFR.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //NL
        List<Lead> lastLeadOwner_LeadAssignNL = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Netherlands' AND Owner.Type = 'User' AND LeadSource != 'Site Agg' AND (Site_Agg_product__c != 'Shell' OR Site_Agg_product__c != 'undefined_card') AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignNL.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //BE FR
        List<Lead> lastLeadOwner_LeadAssignBE_FR = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Belgium-FR' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignBE_FR.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //BE NL
        List<Lead> lastLeadOwner_LeadAssignBE_NL = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Belgium-NL' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignBE_NL.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CH DE
        List<Lead> lastLeadOwner_LeadAssignCH_DE = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Switzerland-DE' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignCH_DE.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CH IT
        List<Lead> lastLeadOwner_LeadAssignCH_IT = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Switzerland-IT' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignCH_IT.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CH FR
        List<Lead> lastLeadOwner_LeadAssignCH_FR = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Switzerland-FR' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignCH_FR.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //LU
        List<Lead> lastLeadOwner_LeadAssignLU = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Luxembourg' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignLU.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CZ
        List<Lead> lastLeadOwner_LeadAssignCZ = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                        (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        Country = 'Czech republic' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND 
                        OwnerId IN :currentMembers_LeadAssignCZ.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //SK
        List<Lead> lastLeadOwner_LeadAssignSK = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                        (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        Country = 'Slovakia' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND 
                        OwnerId IN :currentMembers_LeadAssignSK.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //AllStar
        List<Lead> lastLeadOwner_LeadAssignAllStar = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                        (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        RecordType.Name = 'AllStar' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignAllStar.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //RU
        List<Lead> lastLeadOwner_RussianWebLeads = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Lead_Source_Type__c = 'Webform' OR Lead_Source_Type__c = 'Popup') AND
                        Country = 'Russia' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_RussianWebLeads.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];


        RecordType allstarLeadRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'AllStar' AND SobjectType = 'Lead'
                LIMIT 1];
        
        for (Lead currentLead : newLeads) {
            Boolean isNext = false;
            if (currentLead.Sec_Channel__c == 'Inbound' && currentLead.LeadSource != 'Online_chat' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    (currentLead.Channel__c == 'Internet' || currentLead.Channel__c == 'E-mail') && currentLead.RecordTypeId != allstarLeadRecordType.Id) {
                if (currentLead.CountryCode == 'AT' || currentLead.Country == 'Austria') {
                    if ( ! lastLeadOwner_LeadAssignAT.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAT.get(0).OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'DE' || currentLead.Country == 'Germany') {
                    if ( ! lastLeadOwner_LeadAssignDE.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignDE.get(0).OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'PL' || currentLead.Country == 'Poland') {
                    if ( ! lastLeadOwner_LeadAssignPL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignPL.get(0).OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'HU' || currentLead.Country == 'Hungary') {
                    if ( ! lastLeadOwner_LeadAssignHU.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignHU.get(0).OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'FR' || currentLead.Country == 'France') {
                    if ( ! lastLeadOwner_LeadAssignFR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignFR.get(0).OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'NL' || currentLead.Country == 'Netherlands') {
                    if ( ! lastLeadOwner_LeadAssignNL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignNL.get(0).OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BEFR' || currentLead.Country == 'Belgium-FR') {
                    if ( ! lastLeadOwner_LeadAssignBE_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_FR.get(0).OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BENL' || currentLead.Country == 'Belgium-NL') {
                    if ( ! lastLeadOwner_LeadAssignBE_NL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_NL.get(0).OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHDE' || currentLead.Country == 'Switzerland-DE') {
                    if ( ! lastLeadOwner_LeadAssignCH_DE.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_DE.get(0).OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHIT' || currentLead.Country == 'Switzerland-IT') {
                    if ( ! lastLeadOwner_LeadAssignCH_IT.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_IT.get(0).OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHFR' || currentLead.Country == 'Switzerland-FR') {
                    if ( ! lastLeadOwner_LeadAssignCH_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_FR.get(0).OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'LU' || currentLead.Country == 'Luxembourg') {
                    if ( ! lastLeadOwner_LeadAssignLU.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignLU.get(0).OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CZ' || currentLead.Country == 'Czech Republic') {
                    if ( ! lastLeadOwner_LeadAssignCZ.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCZ.get(0).OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'SK' || currentLead.Country == 'Slovakia') {
                    if ( ! lastLeadOwner_LeadAssignSK.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignSK.get(0).OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    }
                }

            }  else if (currentLead.Sec_Channel__c == 'Inbound' && currentLead.LeadSource != 'Online_chat' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    (currentLead.Channel__c == 'Internet' || currentLead.Channel__c == 'E-mail') && currentLead.RecordTypeId == allstarLeadRecordType.Id) {
                if ( ! lastLeadOwner_LeadAssignAllStar.isEmpty()) {
                    currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAllStar.get(0).OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                } else {
                    currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                }
            }

            if (currentLead.Sec_Channel__c == 'JITB' && currentLead.LeadSource != 'Online_chat' &&
                    currentLead.Channel__c == 'Internet' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    currentLead.RecordTypeId != allstarLeadRecordType.Id) {
                if (currentLead.CountryCode == 'BEFR' || currentLead.Country == 'Belgium-FR') {
                    if ( ! lastLeadOwner_LeadAssignBE_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_FR.get(0).OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BENL' || currentLead.Country == 'Belgium-NL') {
                    if ( ! lastLeadOwner_LeadAssignBE_NL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_NL.get(0).OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'FR' || currentLead.Country == 'France') {
                    if ( ! lastLeadOwner_LeadAssignFR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignFR.get(0).OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'NL' || currentLead.Country == 'Netherlands') {
                    if ( ! lastLeadOwner_LeadAssignNL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignNL.get(0).OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CZ' || currentLead.Country == 'Czech republic') {
                    if ( ! lastLeadOwner_LeadAssignCZ.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCZ.get(0).OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'SK' || currentLead.Country == 'Slovakia') {
                    if ( ! lastLeadOwner_LeadAssignSK.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignSK.get(0).OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'HU' || currentLead.Country == 'Hungary') {
                    // Changed due to new E2E Logic
                    if ( ! lastLeadOwner_LeadAssignHUJITB.isEmpty() && ! LeadHandler.isJITBPortalToE2ELead(currentLead)) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignHUJITB.get(0).OwnerId, queuesMap.get(LeadAssignHUJITB).get(0).Id, currentMembers_LeadAssignHUJITB.values(), alist, null);
                    } else 
                    if ( ! LeadHandler.isJITBPortalToE2ELead(currentLead)) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignHUJITB).get(0).Id, currentMembers_LeadAssignHUJITB.values(), alist, null);
                    }  
                } else if (currentLead.CountryCode == 'PL' || currentLead.Country == 'Poland') {
                    // Changed due to new E2E Logic
                    if ( ! lastLeadOwner_LeadAssignPLJITB.isEmpty() && ! LeadHandler.isJITBPortalToE2ELead(currentLead)) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignPLJITB.get(0).OwnerId, queuesMap.get(LeadAssignPLJITB).get(0).Id, currentMembers_LeadAssignPLJITB.values(), alist, null);
                    } else 
                    if ( ! LeadHandler.isJITBPortalToE2ELead(currentLead)) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignPLJITB).get(0).Id, currentMembers_LeadAssignPLJITB.values(), alist, null);
                    }                    
                }
            } else if (currentLead.Sec_Channel__c == 'JITB' && currentLead.LeadSource != 'Online_chat' &&
                    currentLead.Channel__c == 'Internet' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    currentLead.RecordTypeId == allstarLeadRecordType.Id) {
                if ( ! lastLeadOwner_LeadAssignAllStar.isEmpty()) {
                    currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAllStar.get(0).OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                } else {
                    currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                }
            }

            if (currentLead.Sec_Channel__c == 'Partner' && currentLead.LeadSource != 'Online_chat' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    currentLead.RecordTypeId != allstarLeadRecordType.Id) {
                if (currentLead.CountryCode == 'AT' || currentLead.Country == 'Austria') {
                    if ( ! lastLeadOwner_LeadAssignAT.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAT.get(0).OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'DE' || currentLead.Country == 'Germany') {
                    if ( ! lastLeadOwner_LeadAssignDE.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignDE.get(0).OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'PL' || currentLead.Country == 'Poland') {
                    if ( ! lastLeadOwner_LeadAssignPL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignPL.get(0).OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'HU' || currentLead.Country == 'Hungary') {
                    if ( ! lastLeadOwner_LeadAssignHU.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignHU.get(0).OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'FR' || currentLead.Country == 'France') {
                    if ( ! lastLeadOwner_LeadAssignFR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignFR.get(0).OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'NL' || currentLead.Country == 'Netherlands') {
                    if ( ! lastLeadOwner_LeadAssignNL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignNL.get(0).OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BEFR' || currentLead.Country == 'Belgium-FR') {
                    if ( ! lastLeadOwner_LeadAssignBE_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_FR.get(0).OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BENL' || currentLead.Country == 'Belgium-NL') {
                    if ( ! lastLeadOwner_LeadAssignBE_NL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_NL.get(0).OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHDE' || currentLead.Country == 'Switzerland-DE') {
                    if ( ! lastLeadOwner_LeadAssignCH_DE.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_DE.get(0).OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHIT' || currentLead.Country == 'Switzerland-IT') {
                    if ( ! lastLeadOwner_LeadAssignCH_IT.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_IT.get(0).OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHFR' || currentLead.Country == 'Switzerland-FR') {
                    if ( ! lastLeadOwner_LeadAssignCH_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_FR.get(0).OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'LU' || currentLead.Country == 'Luxembourg') {
                    if ( ! lastLeadOwner_LeadAssignLU.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignLU.get(0).OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CZ' || currentLead.Country == 'Czech Republic') {
                    if ( ! lastLeadOwner_LeadAssignCZ.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCZ.get(0).OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'SK' || currentLead.Country == 'Slovakia') {
                    if ( ! lastLeadOwner_LeadAssignSK.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignSK.get(0).OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    }
                }
            } else if (currentLead.Sec_Channel__c == 'Partner' && currentLead.LeadSource != 'Online_chat' && currentLead.Is_External__c == false &&
                    currentLead.Status != 'Disqualified' && currentLead.RecordTypeId == allstarLeadRecordType.Id) {
                if ( ! lastLeadOwner_LeadAssignAllStar.isEmpty()) {
                    currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAllStar.get(0).OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                } else {
                    currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                }
            }

            if ((currentLead.CountryCode == 'RU' || currentLead.Country == 'Russia') &&
                currentLead.Is_External__c == false &&
                (currentLead.Lead_Source_Type__c == 'Webform' || currentLead.Lead_Source_Type__c == 'Popup') &&
                (currentLead.Source_of_Lead__c == 'Сайт Petrolplus.ru' || currentLead.Source_of_Lead__c == 'Petrolcards.ru - АГГРЕГАТОР')) {
                    Date dueDate = System.today();
                    Date refDate = Date.newInstance(1900, 1, 7);                   // Jan 7 1900 = Sun                  
                    Integer dayOfWeek = Math.mod(refDate.daysBetween(dueDate), 7); // 0 = Sunday ... 6 = Saturday

                    Datetime GMTDate = Datetime.newInstanceGmt(datetime.now().yearGmt(), datetime.now().monthGmt(), datetime.now().dayGmt(),
                                                               datetime.now().hourGmt(), datetime.now().minuteGmt(), 0);
                    integer HourMoscow = Integer.valueOf(GMTDate.format('HH','Europe/Moscow'));
                   
                    if (dayOfWeek >= 1 && dayOfweek<=5 && HourMoscow>=8 && HourMoscow<=17){
                        if ( ! lastLeadOwner_RussianWebLeads.isEmpty()) {
                            currentLead.OwnerId = assignLead(lastLeadOwner_RussianWebLeads.get(0).OwnerId, queuesMap.get(RussianWebLeads).get(0).Id, currentMembers_RussianWebLeads.values(), alist, null);
                        } else {
                            currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(RussianWebLeads).get(0).Id, currentMembers_RussianWebLeads.values(), alist, null);
                        }
                    } else {
                        currentLead.OwneriD=queuesMap.get(RussianWebLeads).get(0).Id;                      
                    }

                }
        }
    }


    /*******************************************************************************
    *  Name            : sendLeadAssignEmail(Map<Id, Lead> newLeads)
    *  Summary         : send assign emails after insert in database
    *  CreatedDate     :
    *  Parameters      : List<Id, Lead> newLeads - new leads values
    *  Returns         : void
    ******************************************************************************/
    public static void sendLeadAssignEmail(Map<Id, Lead> newLeads) {
        List<Messaging.SingleEmailMessage> listtosend = new List<Messaging.SingleEmailMessage>();
        List<Lead> currentLeads = [
                SELECT Owner.Email, Sec_Channel__c, OwnerId, Last_Owner_Change_Date__c, Status, Site_Agg_product__c,
                        Channel__c, LeadSource, Country, RecordType.Name, Owner.Name, Is_External__c,Lead_Source_Type__c
                FROM Lead
                WHERE Id IN :newLeads.keySet() AND 
                    LeadSource != 'Inbound Call' AND 
                    RecordType.Name != 'CCS Sales process' AND 
                    Quali_Status__c != 'Switched to E2E'
                LIMIT 50000];

        List<Lead> finalCurrentLeads = new List<Lead>();
        if (! currentLeads.isEmpty()) {
            for (Lead lead : currentLeads){
                if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                    finalCurrentLeads.add(lead);
                }
            }
            currentLeads = finalCurrentLeads;
        }

        for (Lead currentLead : currentLeads) {
            if (currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    (currentLead.Sec_Channel__c == 'Inbound' || currentLead.Sec_Channel__c == 'JITB') &&
                    (currentLead.Channel__c == 'Internet' || currentLead.Channel__c == 'E-mail')) {
                if (currentLead.Country == 'Austria' || currentLead.Country == 'Germany' ||
                        currentLead.Country == 'France' || currentLead.Country == 'Hungary' ||
                        currentLead.Country == 'Netherlands' || currentLead.Country == 'Poland' ||
                        currentLead.Country == 'Belgium-FR' || currentLead.Country == 'Belgium-NL' ||
                        currentLead.Country == 'Switzerland-DE' || currentLead.Country == 'Switzerland-IT' ||
                        currentLead.Country == 'Switzerland-FR' || currentLead.Country == 'Luxembourg' ||
                        currentLead.Country == 'Czech Republic' || currentLead.Country == 'Slovakia') {
                    String leadownerId = currentLead.OwnerId;
                    if (leadownerId.subString(0,3) == '005' && currentLead.Owner.Email != null && currentLead.Owner.Name != 'Integration Administrator') {
                        listtosend.add(prepareEmail(currentLead.Id, currentLead.OwnerId, currentLead.Owner.Name));
                    }
                }
            }
                if  (currentLead.Is_External__c == false && 
                 (currentLead.Country == 'Russia') &&
                 (currentLead.Lead_Source_Type__c == 'Webform' || currentLead.Lead_Source_Type__c == 'Popup' || 
                  currentLead.Lead_Source_Type__c == 'Chat'    || currentLead.Lead_Source_Type__c == 'Email' ||
                  currentLead.Lead_Source_Type__c == 'Phone_call' )){
                    String leadownerId = currentLead.OwnerId;
                    if (leadownerId.subString(0,3) == '005' && currentLead.Owner.Email != null && currentLead.Owner.Name != 'Integration Administrator') {
                        listtosend.add(prepareEmailRu(currentLead.Id, currentLead.OwnerId, currentLead.Owner.Name));
                    }
                }
        }

        if ( ! listtosend.isEmpty() ) {
            if ( ! Test.isRunningTest() ) {
                try {
                    Messaging.sendEmail(listtosend);
                } catch (Exception e) {
                    system.debug('=== email exception === ' + e.getMessage());
                    system.debug('listtosend === ' + listtosend);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : sendLeadAssignEmail(Map<Id, Lead> newLeads, Map<Id, Lead> oldLeads)
    *  Summary         : send assign emails after update in database
    *  CreatedDate     :
    *  Parameters      : Map<Id, Lead> newLeads - new leads values, Map<Id, Lead> oldLeads - old leads values
    *  Returns         : void
    ******************************************************************************/
    public static void sendLeadAssignEmail(Map<Id, Lead> newLeads, Map<Id, Lead> oldLeads) {
        List<Messaging.SingleEmailMessage> listtosend = new List<Messaging.SingleEmailMessage>();
        List<Lead> currentLeads = [
                SELECT Owner.Email, Sec_Channel__c, OwnerId, Last_Owner_Change_Date__c, Status, Site_Agg_product__c,
                        Channel__c, LeadSource, Country, RecordType.Name, Owner.Name, Is_External__c,Lead_Source_Type__c
                FROM Lead
                WHERE Id IN :newLeads.keySet() AND 
                    LeadSource != 'Inbound Call' AND 
                    RecordType.Name != 'CCS Sales process' AND 
                    Quali_Status__c != 'Switched to E2E'
                LIMIT 50000];

        List<Lead> finalCurrentLeads = new List<Lead>();
        if (! currentLeads.isEmpty()) {
            for (Lead lead : currentLeads){
                if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                    finalCurrentLeads.add(lead);
                }
            }
            currentLeads = finalCurrentLeads;
        }

        for (Lead currentLead : currentLeads) {
            if ((currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    (currentLead.Sec_Channel__c == 'Inbound' || currentLead.Sec_Channel__c == 'JITB') &&
                    (currentLead.Channel__c == 'Internet' || currentLead.Channel__c == 'E-mail')) &&
                    currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    currentLead.OwnerId != oldLeads.get(currentLead.Id).OwnerId) {
                if (currentLead.Country == 'Austria' || currentLead.Country == 'Germany' ||
                        currentLead.Country == 'France' || currentLead.Country == 'Hungary' ||
                        currentLead.Country == 'Netherlands' || currentLead.Country == 'Poland' ||
                        currentLead.Country == 'Belgium-FR' || currentLead.Country == 'Belgium-NL' ||
                        currentLead.Country == 'Switzerland-DE' || currentLead.Country == 'Switzerland-IT' ||
                        currentLead.Country == 'Switzerland-FR' || currentLead.Country == 'Luxembourg' ||
                        currentLead.Country == 'Czech Republic' || currentLead.Country == 'Slovakia' ) {
                    String leadownerId = currentLead.OwnerId;
                    if (leadownerId.subString(0,3) == '005' && currentLead.Owner.Email != null && currentLead.Owner.Name != 'Integration Administrator') {
                        listtosend.add(prepareEmail(currentLead.Id, currentLead.OwnerId, currentLead.Owner.Name));
                    }
                }
            }
            
            if  (currentLead.Is_External__c == false && 
                 (currentLead.Country == 'Russia') &&
                 (currentLead.Lead_Source_Type__c == 'Webform' || currentLead.Lead_Source_Type__c == 'Popup' || 
                  currentLead.Lead_Source_Type__c == 'Chat'    || currentLead.Lead_Source_Type__c == 'Email' ||
                  currentLead.Lead_Source_Type__c == 'Phone_call' ) &&
                  currentLead.OwnerId != oldLeads.get(currentLead.Id).OwnerId){
                    String leadownerId = currentLead.OwnerId;
                    if (leadownerId.subString(0,3) == '005' && currentLead.Owner.Email != null && currentLead.Owner.Name != 'Integration Administrator') {
                        listtosend.add(prepareEmailRu(currentLead.Id, currentLead.OwnerId, currentLead.Owner.Name));
                    }
                }
        }

        if ( ! listtosend.isEmpty()) {
            if ( ! Test.isRunningTest() ) {
                try {
                    Messaging.sendEmail(listtosend);
                } catch (Exception e) {
                    system.debug('=== email exception === ' + e.getMessage());
                    system.debug('listtosend === ' + listtosend);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : prepareEmail(Id leadid, String currentownerid, String ownerName)
    *  Summary         : prepare Email to send
    *  CreatedDate     :
    *  Parameters      : Id leadid - id of lead, String currentownerid - lead owner id, String ownerName - lead owner name
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public static Messaging.SingleEmailMessage prepareEmail(Id leadid, String currentownerid, String ownerName) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {ownerEmail};
        //mail.setToAddresses(toAddresses);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(currentownerid);
        mail.setSenderDisplayName('FleetCor Salesforce');
        mail.setSubject('Lead assigned to you');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Hi ' + ownerName + '! Lead ' + siteurl + leadid + ' assigned to you. Please make the first call in next 10 minutes.');

        return mail;
    }
    
/*******************************************************************************
    *  Name            : prepareEmailRu(Id leadid, String currentownerid, String ownerName)
    *  Summary         : prepare Email to send
    *  CreatedDate     :
    *  Parameters      : Id leadid - id of lead, String currentownerid - lead owner id, String ownerName - lead owner name
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public static Messaging.SingleEmailMessage prepareEmailRu(Id leadid, String currentownerid, String ownerName) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {ownerEmail};
        //mail.setToAddresses(toAddresses);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(currentownerid);
        mail.setSenderDisplayName('FleetCor Salesforce');
        mail.setSubject('Lead assigned to you');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Hi ' + ownerName + '! Lead ' + siteurl + leadid + ' assigned to you.');

        return mail;
    }


    public static void customLeadAssignBatch(List<Lead> leadsList) {
        String ccsRecordTypeId;
        if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CCS Sales process') != null) {
            ccsRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CCS Sales process').getRecordTypeId();
        } 
        List<Lead> newLeads = new List<Lead>();
        for (Lead lead : leadsList) {
            if (lead.RecordTypeId != ccsRecordTypeId && (lead.Recycle_counter__c == 0 || lead.Recycle_counter__c == null) && lead.Quali_Status__c != 'Switched to E2E') {
                newLeads.add(lead);
            }
        }
        
        List<Messaging.SingleEmailMessage> listtosend = new List<Messaging.SingleEmailMessage>();
        LeadRelocationService leadService = new LeadRelocationService();

        List<AuthSession> alist = [
                SELECT Users.Name, LastModifiedDate,LoginType,NumSecondsValid,SessionType
                FROM AuthSession
                WHERE SessionType = 'UI' AND 
                    (LoginType = 'Application' OR LoginType = 'Remote Access Client')
                LIMIT 10000];

        for (Integer i = 0; i < alist.size(); i ++) {
            if (alist.get(i).LastModifiedDate.addSeconds(alist.get(i).NumSecondsValid) < Datetime.now()) {
                alist.remove(i);
            }
        }

        //get all queues
        List<Group> queuesList = [
                SELECT Name, (SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMembers)
                FROM Group
                    WHERE Name = :LeadAssignAT OR Name = :LeadAssignDE OR Name = :LeadAssignPL OR Name = :LeadAssignFR OR
                    Name = :LeadAssignHU OR Name = :LeadAssignNL OR Name = :LeadAssignBE_FR OR Name = :LeadAssignBE_NL OR
                    Name = :LeadAssignCH_DE OR Name = :LeadAssignCH_IT OR Name = :LeadAssignCH_FR OR Name = :LeadAssignLU OR
                    Name = :LeadAssignCZ OR Name = :LeadAssignSK OR Name = :LeadAssignAllStar OR
                    Name = :RussianWebLeads OR Name = :LeadAssignPLJITB OR Name = :LeadAssignHUJITB
                LIMIT 10000];
        Set<Id> queueIdsSet = new Set<Id>();
        for (Group g : queuesList) {
            queueIdsSet.add(g.Id);
        }

        Map<String, List<Group>> queuesMap = new Map<String, List<Group>>();

        for (Group g : queuesList) {
            if ( ! queuesMap.containsKey(g.Name)) {
                queuesMap.put(g.Name, new List<Group>());
            }

            queuesMap.get(g.Name).add(g);
        }

        //LeadAssign
        Map<String, GroupMember> currentMembers_LeadAssignAT = selectGroupMember(LeadAssignAT, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignDE = selectGroupMember(LeadAssignDE, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignPL = selectGroupMember(LeadAssignPL, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignNL = selectGroupMember(LeadAssignNL, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignHU = selectGroupMember(LeadAssignHU, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignFR = selectGroupMember(LeadAssignFR, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignBE_FR = selectGroupMember(LeadAssignBE_FR, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignBE_NL = selectGroupMember(LeadAssignBE_NL, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCH_DE = selectGroupMember(LeadAssignCH_DE, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCH_IT = selectGroupMember(LeadAssignCH_IT, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCH_FR = selectGroupMember(LeadAssignCH_FR, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignLU = selectGroupMember(LeadAssignLU, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignCZ = selectGroupMember(LeadAssignCZ, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignSK = selectGroupMember(LeadAssignSK, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignAllStar = selectGroupMember(LeadAssignAllStar, queuesMap);
        Map<String, GroupMember> currentMembers_RussianWebLeads = selectGroupMember(RussianWebLeads, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignPLJITB = selectGroupMember(LeadAssignPLJITB, queuesMap);
        Map<String, GroupMember> currentMembers_LeadAssignHUJITB = selectGroupMember(LeadAssignHUJITB, queuesMap);

        //AT
        List<Lead> lastLeadOwner_LeadAssignAT = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Austria' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignAT.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //DE
        List<Lead> lastLeadOwner_LeadAssignDE = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Germany' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignDE.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //PL
        List<Lead> lastLeadOwner_LeadAssignPL = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail') AND
                      Country = 'Poland' AND Owner.Type = 'User' AND
                      Last_Owner_Change_Date__c != NULL AND
                      LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                      isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignPL.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //PL JITB
        List<Lead> lastLeadOwner_LeadAssignPLJITB = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE Sec_Channel__c = 'JITB' AND Channel__c = 'Internet' AND
                      Country = 'Poland' AND Owner.Type = 'User' AND
                      Last_Owner_Change_Date__c != NULL AND
                      LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                      isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignPLJITB.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //HU
        List<Lead> lastLeadOwner_LeadAssignHU = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Hungary' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignHU.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //HU JITB
        List<Lead> lastLeadOwner_LeadAssignHUJITB = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                      Country = 'Hungary' AND Owner.Type = 'User' AND
                      Last_Owner_Change_Date__c != NULL AND
                      LeadSource != 'Inbound Call' AND
                      isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignHUJITB.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //FR
        List<Lead> lastLeadOwner_LeadAssignFR = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'France' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignFR.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //NL
        List<Lead> lastLeadOwner_LeadAssignNL = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Netherlands' AND Owner.Type = 'User' AND LeadSource != 'Site Agg' AND (Site_Agg_product__c != 'Shell' OR Site_Agg_product__c != 'undefined_card') AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignNL.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //BE FR
        List<Lead> lastLeadOwner_LeadAssignBE_FR = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Belgium-FR' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignBE_FR.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //BE NL
        List<Lead> lastLeadOwner_LeadAssignBE_NL = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Belgium-NL' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND Status != 'Disqualified' AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_LeadAssignBE_NL.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CH DE
        List<Lead> lastLeadOwner_LeadAssignCH_DE = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        Country = 'Switzerland-DE' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignCH_DE.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CH IT
        List<Lead> lastLeadOwner_LeadAssignCH_IT = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        Country = 'Switzerland-IT' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignCH_IT.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CH FR
        List<Lead> lastLeadOwner_LeadAssignCH_FR = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        Country = 'Switzerland-FR' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignCH_FR.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //LU
        List<Lead> lastLeadOwner_LeadAssignLU = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) AND
                        Country = 'Luxembourg' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignLU.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //CZ
        List<Lead> lastLeadOwner_LeadAssignCZ = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                        (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        Country = 'Czech republic' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND 
                        Status != 'Disqualified' AND 
                        OwnerId IN :currentMembers_LeadAssignCZ.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //SK
        List<Lead> lastLeadOwner_LeadAssignSK = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                        (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        Country = 'Slovakia' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND 
                        Status != 'Disqualified' AND 
                        OwnerId IN :currentMembers_LeadAssignSK.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        //AllStar
        List<Lead> lastLeadOwner_LeadAssignAllStar = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                        (Sec_Channel__c = 'JITB' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail'))) AND
                        RecordType.Name = 'AllStar' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Inbound Call' AND
                        isConverted = FALSE AND Status != 'Disqualified' AND OwnerId IN :currentMembers_LeadAssignAllStar.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        RecordType allstarLeadRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'AllStar' AND SobjectType = 'Lead'
                LIMIT 1];
        
         List<Lead> lastLeadOwner_RussianWebLeads = [
                SELECT OwnerId, Last_Owner_Change_Date__c, Owner.Email
                FROM Lead
                WHERE (Lead_Source_Type__c = 'Webform' OR Lead_Source_Type__c = 'Popup' OR
                       Lead_Source_Type__c = 'Email' OR Lead_Source_Type__c = 'Chat') AND
                        Country = 'Russia' AND Owner.Type = 'User' AND
                        Last_Owner_Change_Date__c != NULL AND
                        isConverted = FALSE AND OwnerId IN :currentMembers_RussianWebLeads.keySet()
                ORDER BY Last_Owner_Change_Date__c DESC
                LIMIT 1];

        for (Lead currentLead : newLeads) {
            Boolean isNext = false;
            Boolean hasSwitchedToE2E = false;
            if ((currentLead.Sec_Channel__c == 'Inbound' && currentLead.Status != 'Disqualified' && (currentLead.Channel__c == 'Internet' || currentLead.Channel__c == 'E-mail')) &&
                    currentLead.Last_Owner_Change_Date__c != null && currentLead.RecordTypeId != allstarLeadRecordType.Id &&
                    (currentLead.Last_Owner_Change_Date__c.addMinutes(9) <= System.now() || queueIdsSet.contains(currentLead.OwnerId))) {
                if (currentLead.Country == 'Austria') {
                    if ( ! lastLeadOwner_LeadAssignAT.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, lastLeadOwner_LeadAssignAT.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Germany') {
                    if ( ! lastLeadOwner_LeadAssignDE.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, lastLeadOwner_LeadAssignDE.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Netherlands') {
                    if ( ! lastLeadOwner_LeadAssignNL.isEmpty() ) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, lastLeadOwner_LeadAssignNL.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Poland') {
                    if ( ! lastLeadOwner_LeadAssignPL.isEmpty() ) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, lastLeadOwner_LeadAssignPL.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Hungary') {
                    if ( ! lastLeadOwner_LeadAssignHU.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, lastLeadOwner_LeadAssignHU.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, null);
                    }
                } else if (currentLead.Country == 'France') {
                    if ( ! lastLeadOwner_LeadAssignFR.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, lastLeadOwner_LeadAssignFR.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Belgium-FR') {
                    if ( ! lastLeadOwner_LeadAssignBE_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, lastLeadOwner_LeadAssignBE_FR.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Belgium-NL') {
                    if ( ! lastLeadOwner_LeadAssignBE_NL.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, lastLeadOwner_LeadAssignBE_NL.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Switzerland-DE') {
                    if ( ! lastLeadOwner_LeadAssignCH_DE.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, lastLeadOwner_LeadAssignCH_DE.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Switzerland-IT') {
                    if ( ! lastLeadOwner_LeadAssignCH_IT.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, lastLeadOwner_LeadAssignCH_IT.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Switzerland-FR') {
                    if ( ! lastLeadOwner_LeadAssignCH_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, lastLeadOwner_LeadAssignCH_FR.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Luxembourg') {
                    if ( ! lastLeadOwner_LeadAssignLU.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, lastLeadOwner_LeadAssignLU.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Czech republic') {
                    if ( ! lastLeadOwner_LeadAssignCZ.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, lastLeadOwner_LeadAssignCZ.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    }
                } else if (currentLead.Country == 'Slovakia') {
                    if ( ! lastLeadOwner_LeadAssignSK.isEmpty()) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, lastLeadOwner_LeadAssignSK.get(0).OwnerId);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    }
                }
            } else if ((currentLead.Sec_Channel__c == 'Inbound' && currentLead.Status != 'Disqualified' && (currentLead.Channel__c == 'Internet' || currentLead.Channel__c == 'E-mail')) &&
                    currentLead.Last_Owner_Change_Date__c != null && currentLead.RecordTypeId == allstarLeadRecordType.Id &&
                    (currentLead.Last_Owner_Change_Date__c.addMinutes(9) <= System.now() || queueIdsSet.contains(currentLead.OwnerId))) {
                if ( ! lastLeadOwner_LeadAssignAllStar.isEmpty()) {
                    currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, lastLeadOwner_LeadAssignAllStar.get(0).OwnerId);
                } else {
                    currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                }
            }

            if (currentLead.Sec_Channel__c == 'JITB' && currentLead.LeadSource != 'Online_chat' && currentLead.RecordTypeId != allstarLeadRecordType.Id &&
                    currentLead.Channel__c == 'Internet' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    (currentLead.Last_Owner_Change_Date__c.addMinutes(9) <= System.now() || queueIdsSet.contains(currentLead.OwnerId))) {
                if (currentLead.CountryCode == 'BEFR' || currentLead.Country == 'Belgium-FR') {
                    if ( ! lastLeadOwner_LeadAssignBE_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_FR.get(0).OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BENL' || currentLead.Country == 'Belgium-NL') {
                    if ( ! lastLeadOwner_LeadAssignBE_NL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_NL.get(0).OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'FR' || currentLead.Country == 'France') {
                    if ( ! lastLeadOwner_LeadAssignFR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignFR.get(0).OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'NL' || currentLead.Country == 'Netherlands') {
                    if ( ! lastLeadOwner_LeadAssignNL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignNL.get(0).OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CZ' || currentLead.Country == 'Czech republic') {
                    if ( ! lastLeadOwner_LeadAssignCZ.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCZ.get(0).OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'SK' || currentLead.Country == 'Slovakia') {
                    if ( ! lastLeadOwner_LeadAssignSK.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignSK.get(0).OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'HU' || currentLead.Country == 'Hungary') {
                    // Change by Eugene due to new functionality of E2E
                    for (LeadHistory lh : currentLead.Histories) {
                        if (lh.OldValue == 'Switched to E2E' && lh.NewValue == null) {
                            hasSwitchedToE2E = true;
                            break;
                        }
                    }
                    if ( ! lastLeadOwner_LeadAssignHUJITB.isEmpty() && (! LeadHandler.isJITBPortalToE2ELead(currentLead) || hasSwitchedToE2E)) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignHUJITB.get(0).OwnerId, queuesMap.get(LeadAssignHUJITB).get(0).Id, currentMembers_LeadAssignHUJITB.values(), alist, null);
                    } else 
                    if ( ! LeadHandler.isJITBPortalToE2ELead(currentLead) || hasSwitchedToE2E) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignHUJITB).get(0).Id, currentMembers_LeadAssignHUJITB.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'PL' || currentLead.Country == 'Poland') {
                    // Change by Eugene due to new functionality of E2E
                    for (LeadHistory lh : currentLead.Histories) {
                        if (lh.OldValue == 'Switched to E2E' && lh.NewValue == null) {
                            hasSwitchedToE2E = true;
                            break;
                        }
                    }
                    if ( ! lastLeadOwner_LeadAssignPLJITB.isEmpty() && (! LeadHandler.isJITBPortalToE2ELead(currentLead) || hasSwitchedToE2E)) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignPLJITB.get(0).OwnerId, queuesMap.get(LeadAssignPLJITB).get(0).Id, currentMembers_LeadAssignPLJITB.values(), alist, null);
                    } else 
                    if ( ! LeadHandler.isJITBPortalToE2ELead(currentLead) || hasSwitchedToE2E) {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignPLJITB).get(0).Id, currentMembers_LeadAssignPLJITB.values(), alist, null);
                    }
                }
            } else if (currentLead.Sec_Channel__c == 'JITB' && currentLead.LeadSource != 'Online_chat' && currentLead.RecordTypeId == allstarLeadRecordType.Id &&
                    currentLead.Channel__c == 'Internet' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    (currentLead.Last_Owner_Change_Date__c.addMinutes(9) <= System.now() || queueIdsSet.contains(currentLead.OwnerId))) {
                if ( ! lastLeadOwner_LeadAssignAllStar.isEmpty()) {
                    currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAllStar.get(0).OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                } else {
                    currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                }
            }
            if (currentLead.Sec_Channel__c == 'Partner' && currentLead.LeadSource != 'Online_chat' && currentLead.Is_External__c == false && currentLead.Status != 'Disqualified' &&
                    currentLead.RecordTypeId != allstarLeadRecordType.Id && (currentLead.Last_Owner_Change_Date__c.addMinutes(9) <= System.now() || queueIdsSet.contains(currentLead.OwnerId))) {
                if (currentLead.CountryCode == 'AT' || currentLead.Country == 'Austria') {
                    if ( ! lastLeadOwner_LeadAssignAT.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAT.get(0).OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAT).get(0).Id, currentMembers_LeadAssignAT.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'DE' || currentLead.Country == 'Germany') {
                    if ( ! lastLeadOwner_LeadAssignDE.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignDE.get(0).OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignDE).get(0).Id, currentMembers_LeadAssignDE.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'PL' || currentLead.Country == 'Poland') {
                    if ( ! lastLeadOwner_LeadAssignPL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignPL.get(0).OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignPL).get(0).Id, currentMembers_LeadAssignPL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'HU' || currentLead.Country == 'Hungary') {
                    if ( ! lastLeadOwner_LeadAssignHU.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignHU.get(0).OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignHU).get(0).Id, currentMembers_LeadAssignHU.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'FR' || currentLead.Country == 'France') {
                    if ( ! lastLeadOwner_LeadAssignFR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignFR.get(0).OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignFR).get(0).Id, currentMembers_LeadAssignFR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'NL' || currentLead.Country == 'Netherlands') {
                    if ( ! lastLeadOwner_LeadAssignNL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignNL.get(0).OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignNL).get(0).Id, currentMembers_LeadAssignNL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BEFR' || currentLead.Country == 'Belgium-FR') {
                    if ( ! lastLeadOwner_LeadAssignBE_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_FR.get(0).OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_FR).get(0).Id, currentMembers_LeadAssignBE_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'BENL' || currentLead.Country == 'Belgium-NL') {
                    if ( ! lastLeadOwner_LeadAssignBE_NL.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignBE_NL.get(0).OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignBE_NL).get(0).Id, currentMembers_LeadAssignBE_NL.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHDE' || currentLead.Country == 'Switzerland-DE') {
                    if ( ! lastLeadOwner_LeadAssignCH_DE.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_DE.get(0).OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_DE).get(0).Id, currentMembers_LeadAssignCH_DE.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHIT' || currentLead.Country == 'Switzerland-IT') {
                    if ( ! lastLeadOwner_LeadAssignCH_IT.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_IT.get(0).OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_IT).get(0).Id, currentMembers_LeadAssignCH_IT.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CHFR' || currentLead.Country == 'Switzerland-FR') {
                    if ( ! lastLeadOwner_LeadAssignCH_FR.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCH_FR.get(0).OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCH_FR).get(0).Id, currentMembers_LeadAssignCH_FR.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'LU' || currentLead.Country == 'Luxembourg') {
                    if ( ! lastLeadOwner_LeadAssignLU.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignLU.get(0).OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignLU).get(0).Id, currentMembers_LeadAssignLU.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'CZ' || currentLead.Country == 'Czech Republic') {
                    if ( ! lastLeadOwner_LeadAssignCZ.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignCZ.get(0).OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignCZ).get(0).Id, currentMembers_LeadAssignCZ.values(), alist, null);
                    }
                } else if (currentLead.CountryCode == 'SK' || currentLead.Country == 'Slovakia') {
                    if ( ! lastLeadOwner_LeadAssignSK.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignSK.get(0).OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignSK).get(0).Id, currentMembers_LeadAssignSK.values(), alist, null);
                    }
                }
            } else if (currentLead.Sec_Channel__c == 'Partner' && currentLead.LeadSource != 'Online_chat' && currentLead.Is_External__c == false &&
                    currentLead.Status != 'Disqualified' && currentLead.RecordTypeId == allstarLeadRecordType.Id && 
                    (currentLead.Last_Owner_Change_Date__c.addMinutes(9) <= System.now() || queueIdsSet.contains(currentLead.OwnerId))) {
                if ( ! lastLeadOwner_LeadAssignAllStar.isEmpty()) {
                    currentLead.OwnerId = assignLead(lastLeadOwner_LeadAssignAllStar.get(0).OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                } else {
                    currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(LeadAssignAllStar).get(0).Id, currentMembers_LeadAssignAllStar.values(), alist, null);
                }
            }
             if ((currentLead.CountryCode == 'RU' || currentLead.Country == 'Russia') &&
                 (currentLead.Lead_Source_Type__c == 'Webform' || 
                  currentLead.Lead_Source_Type__c == 'Popup' || 
                  currentLead.Lead_Source_Type__c == 'Chat' || 
                  currentLead.Lead_Source_Type__c == 'Email') &&      
                  currentLead.Status != 'Disqualified' ) {
                       if ( !lastLeadOwner_RussianWebLeads.isEmpty()) {
                        currentLead.OwnerId = assignLead(lastLeadOwner_RussianWebLeads.get(0).OwnerId, queuesMap.get(RussianWebLeads).get(0).Id, currentMembers_RussianWebLeads.values(), alist, null);
                       } else {
                        currentLead.OwnerId = assignLead(currentLead.OwnerId, queuesMap.get(RussianWebLeads).get(0).Id, currentMembers_RussianWebLeads.values(), alist, null);
                       }
                    }

        }
    }


    /*******************************************************************************
    *  Name            : selectGroupMember(String groupName, Map<String,List<Group>> queuesMap)
    *  Summary         : collect all users of current queue
    *  CreatedDate     :
    *  Parameters      : String groupName - name of queue, Map<String,List<Group>> queuesMap - map of all users
    *  Returns         : Map<String, GroupMember>
    ******************************************************************************/
    public static Map<String, GroupMember> selectGroupMember(String groupName, Map<String,List<Group>> queuesMap) {
        Map<String, GroupMember> currentMembers = new Map<String, GroupMember>();
        if (queuesMap.containsKey(groupName)) {
            for (GroupMember gm : queuesMap.get(groupName).get(0).GroupMembers) {
                String currentId = String.valueOf(gm.UserOrGroupId);
                if (currentId.subString(0,3) == '005') {
                    currentMembers.put(gm.UserOrGroupId, gm);
                }
            }
        }

        return currentMembers;
    }


    /*******************************************************************************
    *  Name            : assignLead(String lastLeadOwnerId, String queueId, List<GroupMember> currentMembers, List<AuthSession> alist, String lastBarchOwnerId)
    *  Summary         : assign lead on active user 
    *  CreatedDate     : 
    *  Parameters      : String lastLeadOwnerId - lead owner before assign, String queueId - id of queue for current lead country, List<GroupMember> currentMembers - 
                            all users of this queue, List<AuthSession> alist - active Auth users sessions, String lastBarchOwnerId - owner id of Lead similar to current 
    *  Returns         : String
    ******************************************************************************/
    public static String assignLead(String lastLeadOwnerId, String queueId, List<GroupMember> currentMembers, List<AuthSession> alist, String lastBarchOwnerId) {
        String newOwnerId = '';
        if ( ! currentMembers.isEmpty()) {
            //create map for users
            List<String> usersGroupList = new List<String>();
            for (GroupMember m : currentMembers) {
                if (String.valueOf(m.UserOrGroupId).substring(0,3) == '005') {
                    usersGroupList.add(m.UserOrGroupId);
                }
            }

            //list for new assignees
            Set<String> listForNewAssign = new Set<String>();
            Integer uIndex = -1;
            Integer counter = 0;
            for (String uid : usersGroupList) {
                if (uid == lastLeadOwnerId) {
                    uIndex = counter;
                    break;
                }
                counter++;
            }

            if (uIndex == -1) {
                counter = 0;
                for (String uid : usersGroupList) {
                    if (uid == lastBarchOwnerId) {
                        uIndex = counter;
                        break;
                    }
                    counter++;
                }
            }


            counter = uIndex + 1;
            for (String uid : usersGroupList) {
                if (counter < usersGroupList.size()) {
                    listForNewAssign.add(usersGroupList.get(counter));
                }
                counter++;
            }

            counter = 0;
            for (String uid : usersGroupList) {
                if (counter <= uIndex) {
                    listForNewAssign.add(usersGroupList.get(counter));
                }
                counter++;
            }

            //get active users from the group
            Set<String> currentActive = new Set<String>();

            for (AuthSession a : alist) {
                currentActive.add(a.UsersId);
            }

            //get new owner id
            Boolean isOneOnline = true;
            Boolean isTwoOnline = false;
            Integer counterOnline = 0;
            for (String ownerid : listForNewAssign) {
                if (currentActive.contains(ownerid)) {
                    counterOnline++;
                }
            }

            if (counterOnline > 1) {
                isOneOnline = false;
                if (counterOnline == 2) {
                    isTwoOnline = true;
                }
            }

            for (String ownerid : listForNewAssign) {
                if (lastBarchOwnerId != null) {
                    if (currentActive.contains(ownerid)) {
                        if (! currentActive.contains(lastLeadOwnerId)) {
                            if (ownerid != lastBarchOwnerId) {
                                newOwnerId = ownerid;
                                break;
                            } else if (isOneOnline) {
                                newOwnerId = ownerid;
                                break;
                            }
                        } else {
                            if (ownerid != lastBarchOwnerId && ownerId != lastLeadOwnerId) {
                                newOwnerId = ownerid;
                                break;
                            } else if (ownerId != lastLeadOwnerId && isTwoOnline == true) {
                                newOwnerId = ownerid;
                                break;
                            } else if (isOneOnline) {
                                newOwnerId = ownerid;
                                break;
                            }
                        }
                    }
                } else {
                    if (currentActive.contains(ownerid)) {
                        newOwnerId = ownerid;
                        break;
                    }
                }
            }

            //if no active assign to queue
            if (String.isBlank(newOwnerId)) {
                newOwnerId = queueId;
            }

            return newOwnerId;
        } else {
            return queueId;
        }
    }
}