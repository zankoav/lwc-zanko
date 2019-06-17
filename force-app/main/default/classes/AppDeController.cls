public class AppDeController {
    
    public String getStep(){
        return ApexPages.currentPage().getParameters().get('step');
    }
}