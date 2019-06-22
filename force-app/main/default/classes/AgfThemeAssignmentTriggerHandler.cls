public with sharing class AgfThemeAssignmentTriggerHandler {

    /*******************************************************************************
    *  Name            : updateWorkThemeField
    *  Summary         : update(AFTER) field ThemesAll__c for parent work
    *  CreatedDate     : 23/03/2018
    *  Parameters      : Map<id, agf__ADM_Theme_Assignment__c> themeMap
    *  Returns         : void
    ******************************************************************************/
    public static void updateWorkThemeField(Map<id, agf__ADM_Theme_Assignment__c> themeMap){
        Set<Id> parentWorkIds = new Set<Id>();
        for(agf__ADM_Theme_Assignment__c theme : themeMap.values()){
            parentWorkIds.add(theme.agf__Work__c);
        }

        List<agf__ADM_Work__c> parentWorks = [
                SELECT id, ThemesAll__c
                FROM agf__ADM_Work__c
                WHERE id in :parentWorkIds
        ];

        Map<Id, agf__ADM_Theme_Assignment__c> currentThemes =
                new Map<Id, agf__ADM_Theme_Assignment__c>([
                        SELECT id, agf__Theme__r.name, agf__Work__c
                        FROM agf__ADM_Theme_Assignment__c
                        WHERE agf__Work__c in :parentWorkIds
                        ORDER BY agf__Work__c, agf__Theme__r.name
                ]);

        if ( !parentWorks.isEmpty() ){
            for(agf__ADM_Work__c currentWork : parentWorks){
                String newThemesAll = '';
                for(agf__ADM_Theme_Assignment__c theme : currentThemes.values()){
                    if(currentWork.id == theme.agf__Work__c){
                        if (newThemesAll == ''){
                            newThemesAll = currentThemes.get(theme.id).agf__Theme__r.name;
                        }
                        else {
                            newThemesAll += ' | ' + currentThemes.get(theme.id).agf__Theme__r.name;
                        }
                    }
                }
                currentWork.ThemesAll__c = newThemesAll;
            }
            update parentWorks;
        }
    }

}