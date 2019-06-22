public class E2EMenuController {
	public Map<String,Object> menuContentMap {get; set;}
    public String menuContentName;
    public String currentActiveStep;

    public void init() {
    	StaticResource settings = [SELECT Body FROM StaticResource WHERE Name = :menuContentName LIMIT 1];
        this.menuContentMap = (Map<String, Object>)JSON.deserializeUntyped(settings.Body.toString());
     	for (Object menuItem : this.menuContentMap.values()) {
     		List<Object> menuItemParams = (List<Object>) menuItem;
     		for (Object param : menuItemParams) {
     			Map<String, Object> paramsMap = (Map<String, Object>) param;
     			List<String> stepsRangeSet = String.valueOf(paramsMap.get('steps')).split(',');
	     		if (stepsRangeSet.contains(currentActiveStep)) {
	 				paramsMap.put('step_status', 'step current');
	     		}
	     		param = paramsMap;	
     		}
     	}
    }

    public void setMenuContentName(String menuContent) {
        if (this.menuContentName == null) {
            this.menuContentName = menuContent;
            init();
        }        
    }
    
    public String getMenuContentName() {
        return this.menuContentName;
    }
    
    public void setCurrentActiveStep(String activeStep) {
        if (this.currentActiveStep == null) {
            this.currentActiveStep = activeStep;
        }
    }

    public String getCurrentActiveStep() {
        return this.currentActiveStep;
    }
}