import { LightningElement, track, api } from 'lwc';

export default class Step extends LightningElement {
    
    @track active;
    @api order;

    @api activate(){
        this.active = true;
    }

    @api deactivate(){
        this.active = false;
    }

    renderedCallback(){
        this.stepLWC = this.querySelector('[data-step]');
        if(this.stepLWC){
            this.stepLWC.order = this.order;
        }
    }
}