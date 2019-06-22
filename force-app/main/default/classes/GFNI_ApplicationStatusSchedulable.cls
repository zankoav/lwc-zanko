/**
 * Created by Nikita.Mikhailov on 23.01.2019.
 */
/*******************************************************************************
*  Name            : GFNI_ApplicationStatusSchedulable
*  Summary         : apex schedulable job for sending application status request to check cards status creation
*  CreatedDate     : 23.01.2019
*  Parameters      :
*  Returns         : void
******************************************************************************/
public with sharing class GFNI_ApplicationStatusSchedulable implements Schedulable {

    /*******************************************************************************
    *  Name            : execute
    *  Summary         : Gathering opp-tys with Pending cards, sorts by countries and calls GFNI_Handler.checkCardStatus for each country
    *  CreatedDate     : 23.01.2019
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    public void execute(SchedulableContext context) {

        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
                SELECT Id, Account.BillingCountryCode
                FROM Opportunity
                WHERE GFNI_ApplicationId__c != null
                AND GFN_Nr__c != null
                AND Id IN (SELECT Opportunity__c FROM Tankkarten__c WHERE GFNI_Status__c = 'Pending')
                //AND Id = '0069E00000ABJWeQAP'
        ]);

        //logic defined by country. Request must be created for each country
        Map<String, Map<Id, Opportunity>> opportunitiesMapByCountry = new Map<String, Map<Id, Opportunity>>();

        for (Opportunity opp : opportunitiesMap.values()) {
            switch on opp.Account.BillingCountryCode.substring(0, 2) {
                when 'DE' {
                    if (opportunitiesMapByCountry.get('DE') == null)
                        opportunitiesMapByCountry.put('DE', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('DE').put(opp.Id, opp);
                }
                when 'AT' {
                    if (opportunitiesMapByCountry.get('AT') == null)
                        opportunitiesMapByCountry.put('AT', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('AT').put(opp.Id, opp);
                }
                when 'CH' {
                    if (opportunitiesMapByCountry.get('CH') == null)
                        opportunitiesMapByCountry.put('CH', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('CH').put(opp.Id, opp);
                }
                when 'BE' {
                    if (opportunitiesMapByCountry.get('BE') == null)
                        opportunitiesMapByCountry.put('BE', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('BE').put(opp.Id, opp);
                }
                when 'LU' {
                    if (opportunitiesMapByCountry.get('LU') == null)
                        opportunitiesMapByCountry.put('LU', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('LU').put(opp.Id, opp);
                }
                when 'HU' {
                    if (opportunitiesMapByCountry.get('HU') == null)
                        opportunitiesMapByCountry.put('HU', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('HU').put(opp.Id, opp);
                }
                when 'NL' {
                    if (opportunitiesMapByCountry.get('NL') == null)
                        opportunitiesMapByCountry.put('NL', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('NL').put(opp.Id, opp);
                }
                when 'FR' {
                    if (opportunitiesMapByCountry.get('FR') == null)
                        opportunitiesMapByCountry.put('FR', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('FR').put(opp.Id, opp);
                }
                when 'PL' {
                    if (opportunitiesMapByCountry.get('PL') == null)
                        opportunitiesMapByCountry.put('PL', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('PL').put(opp.Id, opp);
                }
                when 'CZ' {
                    if (opportunitiesMapByCountry.get('CZ') == null)
                        opportunitiesMapByCountry.put('CZ', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('CZ').put(opp.Id, opp);
                }
                when 'SK' {
                    if (opportunitiesMapByCountry.get('SK') == null)
                        opportunitiesMapByCountry.put('SK', new Map<Id, Opportunity>());

                    opportunitiesMapByCountry.get('SK').put(opp.Id, opp);
                }
            }
        }

        System.debug(opportunitiesMapByCountry);

        //send request as bulk for every country
        for (Map<Id, Opportunity> opportunities : opportunitiesMapByCountry.values()) {
            System.debug('Sending request for ' + opportunities.values().get(0).Account.BillingCountryCode);
            if (!Test.isRunningTest())
                GFNI_Handler.checkCardStatus(opportunities.keySet());
        }
    }
}