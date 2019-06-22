global class ShortLinkCacheRefresher implements Schedulable{

    private static Cache.OrgPartition orgcache = Cache.Org.getPartition('local.shortlinkcache');

    global void execute(SchedulableContext ctx) {

        List<ShortLinkOBNsRefreshed__c> refreshedList =  ShortLinkOBNsRefreshed__c.getAll().values();
        for(ShortLinkOBNsRefreshed__c obn : refreshedList){
            if(orgcache.contains(obn.Name))
                continue;
            ShortURLHookService.preMakeOpp(obn.Name,1,'Germany');
        }
    }

}