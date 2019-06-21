import { LightningElement } from 'lwc';

export default class FcProductTabs extends LightningElement {

    tabs;

    renderedCallback() {
        this.tabs = this.template.querySelectorAll('c-fc-product-tab');
    }

    tabChange(event) {
        this.tabs.forEach(item => {
            const isTargetTab = item.tabValue === event.target.tabValue
            if(isTargetTab){
                item.changeState("active");
                this.dispatchEvent(
                    new CustomEvent('change', { detail: item.tabValue })
                );
            }else{
                item.changeState(false);
            }
        });
    }
}