import { LightningElement, api } from 'lwc';

export default class FcProductTabs extends LightningElement {

    @api tabs;
    tabElems;

    renderedCallback() {
        this.tabElems = this.template.querySelectorAll('c-fc-product-tab');
    }

    tabChange(event) {
        this.tabElems.forEach(item => {
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