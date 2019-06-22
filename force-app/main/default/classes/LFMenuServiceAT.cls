public class LFMenuServiceAT implements LFMenu {
	Map<Decimal, LongForm_Menu_Item__c> menuItemsMap;


    public LFMenuServiceAT() {}


    /*******************************************************************************
    *  Name            : setMenuItems(String deviceView)
    *  Summary         : generate menu for Cermany Long Form    
    *  CreatedDate     : 02/03/2019
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public void setMenuItems(String deviceView) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Austria');

        List<LongForm_Menu__c> menu = [
            SELECT Id, (SELECT Order__c, Step_Name__c, Device_View__c FROM Long_Form_Menu_Items__r ORDER BY Order__c ASC LIMIT 15)
            FROM LongForm_Menu__c
            WHERE Long_Form__r.Country__c = 'Austria' AND 
                  Long_Form__r.Test_mode__c = :settings.Test_mode__c
            LIMIT 1
        ];

        menuItemsMap = new Map<Decimal, LongForm_Menu_Item__c>();
        if (! menu.isEmpty() ) {
            for (LongForm_Menu_Item__c menuItem : menu.get(0).Long_Form_Menu_Items__r) {
                if (menuItem.Device_View__c == deviceView) {
                    menuItemsMap.put(menuItem.Order__c, menuItem);
                }    
            }
        }
    }


    /*******************************************************************************
    *  Name            : getMenuItems()
    *  Summary         : return menu for Cermany Long Form    
    *  CreatedDate     : 02/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<Decimal, LongForm_Menu_Item__c> menuItemsMap
    ******************************************************************************/
    public Map<Decimal, LongForm_Menu_Item__c> getMenuItems() {
        return menuItemsMap;
    }
}